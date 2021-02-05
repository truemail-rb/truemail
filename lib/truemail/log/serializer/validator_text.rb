# frozen_string_literal: true

module Truemail
  module Log
    module Serializer
      class ValidatorText < Truemail::Log::Serializer::ValidatorBase
        ATTEMPT = 'ATTEMPT #'

        def serialize
          <<~VALIDATION_LOGGER_INFO
            #{txt_info_title}
            #{txt_info_debug}
            #{txt_info_configuration}
          VALIDATION_LOGGER_INFO
        end

        private

        def data_composer(enumerable_object)
          enumerable_object.inject([]) do |formatted_data, (key, value)|
            data =
              case
              when value.is_a?(::Hash) then "\n#{printer(value)}"
              when value.is_a?(::Array) then value.join(', ')
              else value
              end
            formatted_data << "#{key.to_s.tr('_', ' ')}: #{data}".chomp << "\n"
          end
        end

        def collection_printer(collection)
          collection.inject([]) { |array, hash| array << printer(hash) }.map.with_index do |item, index|
            "\n#{Truemail::Log::Serializer::ValidatorText::ATTEMPT}#{index + 1}:\n#{item}\n"
          end
        end

        def printer(enumerable_object)
          if enumerable_object.is_a?(Hash)
            data_composer(enumerable_object)
          else
            collection_printer(enumerable_object)
          end.join.chomp
        end

        def error_info
          validation_errors = result[:errors]
          validation_errors ? " (#{printer(validation_errors).tr("\n", ', ')})" : validation_errors
        end

        def txt_info_title
          validation_result = result[:success] ? 'was successful' : 'failed'
          "Truemail #{result[:validation_type]} validation for #{result[:email]} #{validation_result}#{error_info}"
        end

        def txt_info_debug
          result_smtp_debug = result[:smtp_debug]
          "#{printer(result_smtp_debug)}\n" if result_smtp_debug
        end

        def txt_info_configuration
          "CONFIGURATION SETTINGS:\n#{printer(result[:configuration].compact)}"
        end
      end
    end
  end
end
