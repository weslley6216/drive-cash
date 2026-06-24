module Ai
  module Tools
    module QueryWorstPlatform
      def self.declaration
        {
          name:        'query_worst_platform',
          description: 'Informa qual plataforma dá menos lucro por corrida.',
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
