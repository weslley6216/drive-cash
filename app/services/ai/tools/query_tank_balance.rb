module Ai
  module Tools
    module QueryTankBalance
      def self.declaration
        {
          name:        'query_tank_balance',
          description: 'Informa o saldo estimado do tanque de combustível do motorista.',
          parameters:  { type: 'OBJECT', properties: {}, required: [] }
        }
      end
    end
  end
end
