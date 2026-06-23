module Ai
  module Tools
    module QueryCategorySpike
      def self.declaration
        {
          name:        'query_category_spike',
          description: 'Informa qual categoria de despesa mais pesou no período.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              year:  { type: 'INTEGER', description: 'Ano (padrão: atual)' },
              month: { type: 'INTEGER', description: 'Mês 1–12 (padrão: atual)' }
            },
            required:   []
          }
        }
      end
    end
  end
end
