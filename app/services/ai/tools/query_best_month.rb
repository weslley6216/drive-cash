module Ai
  module Tools
    module QueryBestMonth
      def self.declaration
        {
          name:        'query_best_month',
          description: 'Informa qual foi o melhor mês de lucro do motorista.',
          parameters:  { type: 'OBJECT', properties: {}, required: [] }
        }
      end
    end
  end
end
