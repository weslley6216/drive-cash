module Ai
  module Tools
    module QueryPerKm
      def self.declaration
        {
          name:        'query_per_km',
          description: 'Informa o lucro por km rodado no período.',
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
