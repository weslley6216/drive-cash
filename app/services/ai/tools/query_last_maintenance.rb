module Ai
  module Tools
    module QueryLastMaintenance
      def self.declaration
        {
          name:        'query_last_maintenance',
          description: 'Informa quando foi a última manutenção de uma categoria específica.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              category: { type: 'STRING', description: 'Tipo: oil_change, oil_filter, air_filter, fuel_filter, tire_rotation, brake_pads, spark_plugs, timing_belt' }
            },
            required:   []
          }
        }
      end
    end
  end
end
