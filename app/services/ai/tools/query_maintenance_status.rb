module Ai
  module Tools
    module QueryMaintenanceStatus
      def self.declaration
        {
          name:        'query_maintenance_status',
          description: 'Informa o status das manutenções do veículo do motorista.',
          parameters:  { type: 'OBJECT', properties: {}, required: [] }
        }
      end
    end
  end
end
