#
#       ActiveFacts Standard SQL Schema Generator
#
# Copyright (c) 2009-2016 Clifford Heath. Read the LICENSE file.
#
require 'digest/sha1'
require 'activefacts/metamodel'
require 'activefacts/registry'
require 'activefacts/compositions'
require 'activefacts/generators'

module ActiveFacts
  module Generators
    # Options are comma or space separated:
    # * delay_fks Leave all foreign keys until the end, not just those that contain forward-references
    # * underscore 
    class SQL
      def initialize composition, options = {}
	@composition = composition
	@options = options
	@delay_fks = options.include? "delay_fks"
	@underscore = options.include?("underscore") ? "_" : ""
      end

      def generate
	@tables_emitted = {}
	@delayed_foreign_keys = []

	generate_schema +
	@composition.
	all_composite.
	sort_by{|composite| composite.mapping.name}.
	map{|composite| generate_table composite}*"\n" + "\n" +
	@delayed_foreign_keys.sort*"\n"
      end

      def table_name_max
	60
      end

      def column_name_max
	40
      end

      def index_name_max
	60
      end

      def schema_name_max
	60
      end

      def safe_table_name composite
	escape(table_name(composite), table_name_max)
      end

      def safe_column_name component
	escape(column_name(component), column_name_max)
      end

      def table_name composite
	composite.mapping.name.gsub(' ', @underscore)
      end

      def column_name component
	component.column_name.capcase
      end

      def generate_schema
	#go "CREATE SCHEMA #{escape(@composition.name, schema_name_max)}" +
	''
      end

      def generate_table composite
	@tables_emitted[composite] = true
	delayed_indices = []

	"CREATE TABLE #{safe_table_name composite} (\n" +
	(
	  composite.mapping.leaves.flat_map do |leaf|
	    # Absorbed empty subtypes appear as leaves
	    next if leaf.is_a?(MM::Absorption) && leaf.parent_role.fact_type.is_a?(MM::TypeInheritance)

	    generate_column leaf
	  end +
	  composite.all_index.map do |index|
	    generate_index index, delayed_indices
	  end.compact.sort +
	  composite.all_foreign_key_as_source_composite.map do |fk|
	    fk_text = generate_foreign_key fk
	    if !@delay_fks and @tables_emitted[fk.composite]
	      fk_text
	    else
	      @delayed_foreign_keys <<
		go("ALTER TABLE #{safe_table_name fk.composite}\n\tADD " + fk_text)
	      nil
	    end
	  end.compact.sort +
	  composite.all_local_constraint.map do |constraint|
	    '-- '+constraint.inspect	# REVISIT: Emit local constraints
	  end
	).compact.flat_map{|f| "\t#{f}" }*",\n"+"\n" +
	go(")") +
	delayed_indices.sort.map do |delayed_index|
	  go delayed_index
	end*"\n"
      end

      def generate_column leaf
	column_name = safe_column_name(leaf)
	padding = " "*(column_name.size >= column_name_max ? 1 : column_name_max-column_name.size)
	constraints = leaf.all_leaf_constraint

	identity = ''
	"-- #{column_comment leaf}\n\t#{column_name}#{padding}#{component_type leaf, column_name}#{identity}"
      end

      def column_comment component
	return '' unless cp = component.parent
	prefix = column_comment(cp)
	name = component.name
	if component.is_a?(MM::Absorption)
	  reading = component.parent_role.fact_type.reading_preferably_starting_with_role(component.parent_role).expand([], false)
	  maybe = component.parent_role.is_mandatory ? '' : 'maybe '
	  cpname = cp.name
	  if prefix[(-cpname.size-1)..-1] == ' '+cpname && reading[0..cpname.size] == cpname+' '
	    prefix+' that ' + maybe + reading[cpname.size+1..-1]
	  else
	    (prefix.empty? ? '' : prefix+' and ') + maybe + reading
	  end
	else
	  name
	end
      end

      def boolean_type
	'BOOLEAN'
      end

      def component_type component, column_name
	case component
	when MM::Indicator
	  boolean_type
	when MM::ValueField, MM::Absorption
	  object_type = component.object_type
	  while object_type.is_a?(MM::EntityType)
	    rr = object_type.preferred_identifier.role_sequence.all_role_ref.single
	    raise "Can't produce a column for composite #{component.inspect}" unless rr
	    object_type = rr.role.object_type
	  end
	  raise "A column can only be produced from a ValueType" unless object_type.is_a?(MM::ValueType)

	  if component.is_a?(MM::Absorption)
	    value_constraint ||= component.child_role.role_value_constraint
	  end

	  supertype = object_type
	  begin
	    object_type = supertype
	    length ||= object_type.length
	    scale ||= object_type.scale
	    unless component.parent.parent and component.parent.foreign_key
	      # No need to enforce value constraints that are already enforced by a foreign key
	      value_constraint ||= object_type.value_constraint
	    end
	  end while supertype = object_type.supertype
	  type, length = normalise_type(object_type.name, length)
	  sql_type = "#{type}#{
	    if !length
	      ''
	    else
	      '(' + length.to_s + (scale ? ", #{scale}" : '') + ')'
	    end
	  }#{
	    (component.path_mandatory ? '' : ' NOT') + ' NULL'
	  }#{
	    # REVISIT: This is an SQL Server-ism. Replace with a standard SQL SEQUENCE/
	    # Emit IDENTITY for columns auto-assigned on commit (except FKs)
	    if a = object_type.is_auto_assigned and a != 'assert' and
		!component.all_foreign_key_field.detect{|fkf| fkf.foreign_key.source_composite == component.root}
	      ' IDENTITY'
	    else
	      ''
	    end
	  }#{
	    value_constraint ? check_clause(column_name, value_constraint) : ''
	  }"
	else
	  raise "Can't make a column from #{component}"
	end
      end

      def generate_index index, delayed_indices
	nullable_columns =
	  index.all_index_field.select do |ixf|
	    !ixf.component.path_mandatory
	  end
	contains_nullable_columns = nullable_columns.size > 0

	primary = index.composite_as_primary_index && !contains_nullable_columns
	column_names =
	    index.all_index_field.map do |ixf|
	      column_name(ixf.component)
	    end
	clustering =
	  (index.composite_as_primary_index ? ' CLUSTERED' : ' NONCLUSTERED')

	if contains_nullable_columns
	  delayed_indices <<
	    'CREATE UNIQUE'+clustering+' INDEX '+
	    escape("#{safe_table_name(index.composite)}By#{column_names*''}", index_name_max) +
	    " ON ("+column_names.map{|n| escape(n, column_name_max)}*', ' +
	    ") WHERE #{
	      nullable_columns.
	      map{|ixf| safe_column_name ixf.component}.
	      map{|column_name| column_name + ' IS NOT NULL'} *
	      ' AND '
	    }"
	  nil
	else
	  '-- '+index.inspect + "\n\t" +
	  (primary ? 'PRIMARY KEY' : 'UNIQUE') +
	  clustering +
	  "(#{column_names.map{|n| escape(n, column_name_max)}*', '})"
	end
      end

      def generate_foreign_key fk
	'-- '+fk.inspect
	"FOREIGN KEY (" +
	  fk.all_foreign_key_field.map{|fkf| safe_column_name fkf.component}*", " +
	  ") REFERENCES #{safe_table_name fk.composite} (" +
	  fk.all_index_field.map{|ixf| safe_column_name ixf.component}*", " +
	")"
      end

      def reserved_words
	@reserved_words ||= %w{
	  ADD ALL ALTER AND ANY AS ASC AUTHORIZATION BACKUP BEGIN BETWEEN
	  BREAK BROWSE BULK BY CASCADE CASE CHECK CHECKPOINT CLOSE CLUSTERED
	  COALESCE COLLATE COLUMN COMMIT COMPUTE CONSTRAINT CONTAINS CONTAINSTABLE
	  CONTINUE CONVERT CREATE CROSS CURRENT CURRENT_DATE CURRENT_TIME
	  CURRENT_TIMESTAMP CURRENT_USER CURSOR DATABASE DBCC DEALLOCATE
	  DECLARE DEFAULT DELETE DENY DESC DISK DISTINCT DISTRIBUTED DOUBLE
	  DROP DUMMY DUMP ELSE END ERRLVL ESCAPE EXCEPT EXEC EXECUTE EXISTS
	  EXIT FETCH FILE FILLFACTOR FOR FOREIGN FREETEXT FREETEXTTABLE FROM
	  FULL FUNCTION GOTO GRANT GROUP HAVING HOLDLOCK IDENTITY IDENTITYCOL
	  IDENTITY_INSERT IF IN INDEX INNER INSERT INTERSECT INTO IS JOIN KEY
	  KILL LEFT LIKE LINENO LOAD NATIONAL NOCHECK NONCLUSTERED NOT NULL
	  NULLIF OF OFF OFFSETS ON OPEN OPENDATASOURCE OPENQUERY OPENROWSET
	  OPENXML OPTION OR ORDER OUTER OVER PERCENT PLAN PRECISION PRIMARY
	  PRINT PROC PROCEDURE PUBLIC RAISERROR READ READTEXT RECONFIGURE
	  REFERENCES REPLICATION RESTORE RESTRICT RETURN REVOKE RIGHT ROLLBACK
	  ROWCOUNT ROWGUIDCOL RULE SAVE SCHEMA SELECT SESSION_USER SET SETUSER
	  SHUTDOWN SOME STATISTICS SYSTEM_USER TABLE TEXTSIZE THEN TO TOP
	  TRAN TRANSACTION TRIGGER TRUNCATE TSEQUAL UNION UNIQUE UPDATE
	  UPDATETEXT USE USER VALUES VARYING VIEW WAITFOR WHEN WHERE WHILE
	  WITH WRITETEXT
	}
      end

      def is_reserved_word w
	@reserved_word_hash ||=
	  reserved_words.inject({}) do |h,w|
	    h[w] = true
	    h
	  end
	@reserved_word_hash[w.upcase]
      end

      def go s = ''
	"#{s}\nGO\n"  # REVISIT: This is an SQL-Serverism. Move it to a subclass.
      end

      def escape s, max = table_name_max
	# Escape SQL keywords and non-identifiers
	if s.size > max
	  excess = s[max..-1]
	  s = s[0...max-(excess.size/8)] +
	    Digest::SHA1.hexdigest(excess)[0...excess.size/8]
	end

	if s =~ /[^A-Za-z0-9_]/ || is_reserved_word(s)
	  "[#{s}]"
	else
	  s
	end
      end

      # Return SQL type and (modified?) length for the passed base type
      def normalise_type(type, length)
	sql_type = case type
	  when /^Auto ?Counter$/
	    'int'

	  when /^Unsigned ?Integer$/,
	    /^Signed ?Integer$/,
	    /^Unsigned ?Small ?Integer$/,
	    /^Signed ?Small ?Integer$/,
	    /^Unsigned ?Tiny ?Integer$/
	    s = case
	      when length == nil
		'int'
	      when length <= 8
		'tinyint'
	      when length <= 16
		'smallint'
	      when length <= 32
		'int'
	      else
		'bigint'
	      end
	    length = nil
	    s

	  when /^Decimal$/
	    'decimal'

	  when /^Fixed ?Length ?Text$/, /^Char$/
	    'char'
	  when /^Variable ?Length ?Text$/, /^String$/
	    'varchar'
	  when /^Large ?Length ?Text$/, /^Text$/
	    'text'

	  when /^Date ?And ?Time$/, /^Date ?Time$/
	    'datetime'
	  when /^Date$/
	    'datetime' # SQLSVR 2K5: 'date'
	  when /^Time$/
	    'datetime' # SQLSVR 2K5: 'time'
	  when /^Auto ?Time ?Stamp$/
	    'timestamp'

	  when /^Guid$/
	    'uniqueidentifier'
	  when /^Money$/
	    'decimal'
	  when /^Picture ?Raw ?Data$/, /^Image$/
	    'image'
	  when /^Variable ?Length ?Raw ?Data$/, /^Blob$/
	    'varbinary'
	  when /^BIT$/
	    'bit'
	  else type # raise "SQL type unknown for standard type #{type}"
	  end
	[sql_type, length]
      end

      def sql_value(value)
	value.is_literal_string ? sql_string(value.literal) : value.literal
      end

      def sql_string(str)
	"'" + str.gsub(/'/,"''") + "'"
      end

      def check_clause column_name, value_constraint
	" CHECK(" +
	  value_constraint.all_allowed_range_sorted.map do |ar|
	    vr = ar.value_range
	    min = vr.minimum_bound
	    max = vr.maximum_bound
	    if (min && max && max.value.literal == min.value.literal)
	      "#{column_name} = #{sql_value(min.value)}"
	    else
	      inequalities = [
		min && "#{column_name} >#{min.is_inclusive ? "=" : ""} #{sql_value(min.value)}",
		max && "#{column_name} <#{max.is_inclusive ? "=" : ""} #{sql_value(max.value)}"
	      ].compact
	      inequalities.size > 1 ? "(" + inequalities*" AND " + ")" : inequalities[0]
	    end
	  end*" OR " +
	")"
      end

      MM = ActiveFacts::Metamodel
    end
    publish_generator SQL
  end
end
