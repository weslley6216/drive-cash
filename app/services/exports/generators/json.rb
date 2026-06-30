module Exports
  module Generators
    class Json
      File = Data.define(:io, :filename, :content_type)

      def self.call(payload:)
        new(payload: payload).call
      end

      def initialize(payload:)
        @payload = payload
      end

      def call
        document = {
          earnings:     stringify(@payload.earnings),
          expenses:     stringify(@payload.expenses),
          refuelings:   stringify(@payload.refuelings),
          maintenances: stringify(@payload.maintenances),
          totals:       stringify(@payload.totals)
        }

        io = StringIO.new(JSON.pretty_generate(document))
        File.new(io: io, filename: "drivecash-export-#{Time.current.to_i}.json", content_type: 'application/json')
      end

      private

      def stringify(value)
        case value
        when Array then value.map { |row| stringify(row) }
        when Hash then value.transform_values { |inner| stringify(inner) }
        when BigDecimal then value.to_s('F')
        when Date then value.iso8601
        else value
        end
      end
    end
  end
end
