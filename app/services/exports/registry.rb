module Exports
  module Registry
    class UnknownFormat < StandardError; end

    GENERATORS = {
      'pdf'  => 'Exports::Generators::Pdf',
      'csv'  => 'Exports::Generators::Csv',
      'json' => 'Exports::Generators::Json'
    }.freeze

    def self.for(format_key)
      class_name = GENERATORS.fetch(format_key.to_s) { raise UnknownFormat, "no generator for format=#{format_key}" }
      class_name.constantize
    end
  end
end
