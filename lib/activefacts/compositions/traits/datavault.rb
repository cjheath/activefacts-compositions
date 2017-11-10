module ActiveFacts
  module Compositions
    module Traits
      module DataVault
        def datavault_options
          {
            datestamp: ['String', "Data type name to use for data vault date stamps (default: DateTime)"],
            recordsource: ['String', "Data type name to use for data vault record source (default: String)"],
          }
        end

        def datavault_initialize options
          @option_datestamp = options.delete('datestamp')
          @option_datestamp = 'DateTime' if [true, '', 'true', 'yes', nil].include?(@option_datestamp)
          @option_recordsource = options.delete('recordsource')
          @option_recordsource = 'String' if [true, '', 'true', 'yes', nil].include?(@option_recordsource)
        end

        #
        # Datetime and recordsource functions defined here because they are used in both Staging and Datavault subclasses
        #
        def inject_datetime_recordsource mapping
          # Add a load DateTime value
          date_field = @constellation.ValidFrom(:new,
            parent: mapping,
            name: "LoadTime",
            object_type: datestamp_type
          )

          # Add a load DateTime value
          recsrc_field = @constellation.ValueField(:new,
            parent: mapping,
            name: "RecordSource",
            object_type: recordsource_type
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
            composite.mapping.name = apply_name_pattern(@option_stg_name, composite.mapping.name)
          end
        end
      end
    end
  end
end
