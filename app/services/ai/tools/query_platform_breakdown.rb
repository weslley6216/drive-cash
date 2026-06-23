module Ai
  module Tools
    module QueryPlatformBreakdown
      def self.declaration
        {
          name:        'query_platform_breakdown',
          description: 'Informa quanto o motorista ganhou por plataforma no período.',
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
