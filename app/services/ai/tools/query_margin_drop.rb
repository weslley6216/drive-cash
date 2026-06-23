module Ai
  module Tools
    module QueryMarginDrop
      def self.declaration
        {
          name:        'query_margin_drop',
          description: 'Informa se a margem de lucro caiu em relação ao período anterior.',
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
