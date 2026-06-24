module Ai
  module Tools
    module UpdateMaintenance
      def self.declaration
        {
          name:        'update_maintenance',
          description: 'Registra que o motorista realizou uma manutenção no veículo.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              category: { type: 'STRING', description: 'Tipo: oil_change, oil_filter, air_filter, fuel_filter, tire_rotation, brake_pads, spark_plugs, timing_belt' },
              done_km:  { type: 'INTEGER', description: 'Km em que foi feita (padrão: odômetro atual do veículo)' }
            },
            required:   ['category']
          }
        }
      end
    end
  end
end
