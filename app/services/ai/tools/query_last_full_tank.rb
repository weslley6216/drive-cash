module Ai
  module Tools
    module QueryLastFullTank
      def self.declaration
        {
          name:        'query_last_full_tank',
          description: 'Informa quando foi o último tanque cheio do motorista.',
          parameters:  { type: 'OBJECT', properties: {}, required: [] }
        }
      end
    end
  end
end
