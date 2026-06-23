module Ai
  module Tools
    module QuerySummary
      def self.declaration
        {
          name:        'query_summary',
          description: 'Responde perguntas sobre lucro, ganhos e despesas do motorista em um período.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              year:  { type: 'INTEGER', description: 'Ano (padrão: ano atual)' },
              month: { type: 'INTEGER', description: 'Mês 1–12 (omitir para ver o ano todo)' }
            },
            required:   []
          }
        }
      end
    end
  end
end
