module Ai
  module Tools
    module QueryVendorEfficiency
      def self.declaration
        {
          name:        'query_vendor_efficiency',
          description: 'Informa qual posto de gasolina é mais econômico em km/L.',
          parameters:  { type: 'OBJECT', properties: {}, required: [] }
        }
      end
    end
  end
end
