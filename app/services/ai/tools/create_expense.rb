module Ai
  module Tools
    module CreateExpense
      def self.declaration
        {
          name:        'create_expense',
          description: 'Registra uma despesa do motorista. Use OBRIGATORIAMENTE quando mencionar um gasto.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              amount:              { type: 'NUMBER', description: 'Valor numérico em reais (total da compra). OBRIGATORIAMENTE um número. Ex: 50.0, 1200.0' },
              category:            { type: 'STRING', description: 'Categoria: fuel, maintenance, car_wash, toll, parking, documentation, insurance, fine, meals, phone, other' },
              date:                { type: 'STRING', description: 'Data no formato YYYY-MM-DD da primeira parcela ou da despesa única.' },
              vendor:              { type: 'STRING', description: 'Estabelecimento ou fornecedor' },
              description:         { type: 'STRING', description: 'Observação adicional opcional. Não usar para repetir a categoria.' },
              installments:        { type: 'INTEGER', description: 'Opcional. Número de parcelas/compromissos (mínimo 2). Cada parcela nasce como "a pagar" até confirmar quitada no cadastro.' },
              installments_period: { type: 'STRING', description: 'Obrigatório se installments >= 2: weekly, biweekly, monthly ou annual' }
            },
            required:   ['amount', 'category', 'date']
          }
        }
      end
    end
  end
end
