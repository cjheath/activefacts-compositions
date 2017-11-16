module ActiveFacts
  module Compositions
    module Traits
      module DataVault
        def datavault_options
          {
            datestamp: ['String', "Data type name to use for data vault date stamps (default: DateTime)"],
            recordsource: ['String', "Data type name to use for data vault record source (default: String)"],
            loadbatch: ['String', "Create a load batch table using this name, default LoadBatch"],
          }
        end

        def datavault_initialize options
          @option_datestamp = options.delete('datestamp')
          @option_datestamp = 'DateTime' if [true, '', 'true', 'yes', nil].include?(@option_datestamp)
          @option_recordsource = options.delete('recordsource')
          @option_recordsource = 'String' if [true, '', 'true', 'yes', nil].include?(@option_recordsource)
          @option_loadbatch = options.delete('loadbatch')
          @option_loadbatch = 'LoadBatch' if [true, 'true', 'yes'].include?(@option_loadbatch)
          @option_loadbatch = nil if [false, 'false', ''].include?(@option_loadbatch)
        end

        def create_loadbatch
          vocabulary = @constellation.Vocabulary.values[0]

          schema_text = %Q{
            schema #{vocabulary.name};

            each #{@option_loadbatch} ID is written as an Auto Counter auto-assigned at commit;
            each #{@option_loadbatch} is independent identified by its ID;
            each #{@option_datestamp} is written as a #{@option_datestamp};
            #{@option_loadbatch} began at one start-#{@option_datestamp};
          }
          @compiler = ActiveFacts::CQL::Compiler.new(@vocabulary, constellation: @constellation)
          @compiler.compile(schema_text)
          @loadbatch_entity_type = @constellation.EntityType[[vocabulary.identifying_role_values, @option_loadbatch]]
        end

        def inject_loadbatch_relationships
          return unless @option_loadbatch
          @composition.all_composite.each do |composite|
            next if composite.mapping.object_type.name == @option_loadbatch
            @compiler.compile("#{composite.mapping.name} was loaded in one #{@option_loadbatch};")
          end
          @loadbatch_entity_type.all_role.each do |role|
            populate_reference role
            populate_reference role.counterpart
          end
        end

        def inject_datetime_recordsource mapping
          # Add a load DateTime value
          date_field = @constellation.ValidFrom(:new,
            parent: mapping,
            name: "LoadTime",
            object_type: datestamp_type,
            injection_annotation: "datavault"
          )

          # Add a load DateTime value
          recsrc_field = @constellation.ValueField(:new,
            parent: mapping,
            name: "RecordSource",
            object_type: recordsource_type,
            injection_annotation: "datavault"
          )
          mapping.re_rank
          date_field
        end

        def datestamp_type_name
          @option_datestamp
        end

        def datestamp_type
          @datestamp_type ||= begin
            vocabulary = @composition.all_composite.to_a[0].mapping.object_type.vocabulary
            @constellation.ObjectType[[[vocabulary.name], datestamp_type_name]] or
              @constellation.ValueType(
                vocabulary: vocabulary,
                name: datestamp_type_name,
                concept: [:new, :implication_rule => "datestamp injection"]
              )
          end
        end

        def recordsource_type_name
          @option_recordsource
        end

        def recordsource_type
          @recordsource_type ||= begin
            vocabulary = @composition.all_composite.to_a[0].mapping.object_type.vocabulary
            @constellation.ObjectType[[[vocabulary.name], recordsource_type_name]] or
              @constellation.ValueType(
                vocabulary: vocabulary,
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
            next if composite.mapping.object_type.name == @option_loadbatch
            composite.mapping.name = apply_name_pattern(@option_stg_name, composite.mapping.name)
          end
        end
      end
    end
  end
end
