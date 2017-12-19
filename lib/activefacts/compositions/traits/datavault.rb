module ActiveFacts
  module Compositions
    module Traits
      module DataVault
        def datavault_options
          {
            # Structural options:
            audit: [%w{record batch}, "Add date/source auditing fields to each record (hub/link/staging) or via a LoadBatch table"],
            # Variation options:
            loadbatch: ['String', "Change the name of the load batch table from LoadBatch"],
            datestamp: ['String', "Data type name to use for audit date stamps (default: DateTime)"],
            source: ['String', "Data type name to use for audit source (default: String)"],
          }
        end

        def datavault_initialize options
          @option_audit = options.delete('audit')

          case @option_loadbatch = options.delete('loadbatch')
          when true, 'true', 'yes'
            @option_loadbatch = 'LoadBatch'
          when false, 'false'
            @option_loadbatch = nil
          end
          @option_loadbatch ||= 'LoadBatch' if @option_audit == 'batch'

          case @option_datestamp = options.delete('datestamp')
          when true, '', 'true', 'yes', nil
            @option_datestamp = 'DateTime'
          when false, 'false'
            @option_datestamp = nil
          end

          case @option_source = options.delete('source')
          when true, '', 'true', 'yes', nil
            @option_source = 'String'
          when false, 'false'
            @option_source = nil
          end

        end

        def compile text
          @vocabulary = @constellation.Vocabulary.values[0]
          @compiler ||= ActiveFacts::CQL::Compiler.new(@vocabulary, constellation: @constellation)
          @compiler.compile("schema #{@vocabulary.name};\n"+text)
        end

        def create_loadbatch
          return unless @option_audit == 'batch' && @option_loadbatch

          schema_text = %Q{
            each #{@option_loadbatch} ID is written as an Auto Counter auto-assigned at commit;
            each #{@option_loadbatch} is independent identified by its ID;
          }
          compile(schema_text)
          @loadbatch_entity_type = @constellation.EntityType[[@vocabulary.identifying_role_values, @option_loadbatch]]
        end

        # This method only works after the LoadBatch composite has been asserted, of course
        def loadbatch_composite
          @loadbatch_composite ||= @composition.
            all_composite.detect{|c| c.mapping.object_type == @loadbatch_entity_type}
        end

        def inject_loadbatch_relationships
          return unless @option_audit == 'batch'
          trace :batch, "Injecting LoadBatch relationships" do
            @composition.all_composite.each do |composite|
              inject_loadbatch_relationship composite
            end
          end
        end

        def inject_loadbatch_relationship composite
          return if composite == loadbatch_composite
          trace :batch, "Injecting LoadBatch relationship into #{composite.mapping.name}" do
            compile("#{composite.mapping.name} was loaded in one #{@option_loadbatch};")

            role = composite.mapping.object_type.all_role.detect{|r| c = r.counterpart and c.object_type == @loadbatch_entity_type}
            version_field = populate_reference(role)
            version_field.injection_annotation = 'loadbatch'
            composite.mapping.re_rank
            loadbatch_composite.mapping.re_rank
            version_field
          end
        end

        def inject_audit_fields composite, copy_from = nil
          version_field = begin
            if @option_audit == 'batch' && composite != @loadbatch_composite
              if copy_from
                # Our hub or link has an FK to LoadBatch already. Fork a copy to use on the satellite
                trace :batch, "Copying LoadBatchID from #{copy_from.mapping.name} into #{composite.mapping.name}" do
                  parent_version_field = @version_fields[copy_from]
                  load_batch = parent_version_field.fork_to_new_parent composite.mapping
                  leaves = parent_version_field.all_leaf
                  raise "WARNING: unexpected audit structure" unless leaves.size == 1
                  version_field = leaves[0].fork_to_new_parent load_batch
                  load_batch.injection_annotation =
                  version_field.injection_annotation =
                    parent_version_field.injection_annotation
                  version_field
                end
              else
                inject_loadbatch_relationship composite
              end
            else
              if datestamp_type
                # Add a load DateTime value
                version_field = @constellation.ValidFrom(:new,
                  parent: composite.mapping,
                  name: "LoadTime",
                  object_type: datestamp_type,
                  injection_annotation: "datavault"
                )
              end

              if recordsource_type
                # Add a load DateTime value
                recsrc_field = @constellation.Mapping(:new,
                  parent: composite.mapping,
                  name: "RecordSource",
                  object_type: recordsource_type,
                  injection_annotation: "datavault"
                )
              end
              version_field
            end

          end
          composite.mapping.re_rank
          (@version_fields ||= {})[composite] = version_field
        end

        def datestamp_type_name
          @option_datestamp
        end

        def datestamp_type
          @datestamp_type ||= begin
            @vocabulary ||= @composition.all_composite.to_a[0].mapping.object_type.vocabulary
            @constellation.ObjectType[[[@vocabulary.name], datestamp_type_name]] or
              @constellation.ValueType(
                vocabulary: @vocabulary,
                name: datestamp_type_name,
                concept: [:new, :implication_rule => "datestamp injection"]
              )
          end
        end

        def recordsource_type_name
          @option_source
        end

        def recordsource_type
          @recordsource_type ||= begin
            @vocabulary ||= @composition.all_composite.to_a[0].mapping.object_type.vocabulary
            @constellation.ObjectType[[[@vocabulary.name], recordsource_type_name]] or
              @constellation.ValueType(
                vocabulary: @vocabulary,
                name: recordsource_type_name,
                concept: [:new]
              )
          end
        end

        #
        # Rename parents functions defined because they are used in both Staging and Datavault subclasses
        #
        def apply_name_pattern pattern, name
          pattern.sub(/\+/, name)
        end

        def apply_composite_name_pattern
          @composites.each do |key, composite|
            next if composite.mapping.name == @option_loadbatch
            composite.mapping.name = apply_name_pattern(@option_stg_name, composite.mapping.name)
          end
        end
      end
    end
  end
end
