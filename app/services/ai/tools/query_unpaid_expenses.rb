module Ai
  module Tools
    module QueryUnpaidExpenses
      def self.declaration
        {
          name:        'query_unpaid_expenses',
          description: 'Lista as despesas não pagas do motorista.',
          parameters:  { type: 'OBJECT', properties: {}, required: [] }
        }
      end
    end
  end
end
