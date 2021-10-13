require 'json'
require 'jsonpath'
module Embulk
  module Guess
    class Jsonpath < TextGuessPlugin
      Plugin.register_guess('jsonpath', self)

      def guess_text(config, sample_text)
        parser_config = config.param('parser', :hash)
        json_path = parser_config.param('root', :string, default: '$')
        json = JsonPath.new(json_path).on(sample_text).first
        json = [json] unless json.is_a?(Array)

        no_hash = json.find { |j| !j.is_a?(Hash) }
        raise "Can't exec guess. The row data must be hash." if no_hash

        columns = Embulk::Guess::SchemaGuess.from_hash_records(json).map do |c|
          column = { name: c.name, type: c.type }
          column[:format] = c.format if c.format
          column
        end
        parser_guessed = { 'type' => 'jsonpath' }
        parser_guessed['columns'] = columns
        { 'parser' => parser_guessed }
      end
    end
  end
end
