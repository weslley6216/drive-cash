module Ai
  module Tools
    module CreateExpense
      def self.declaration
        {
          name: 'create_expense',
          description: 'Registra uma despesa do motorista. Use OBRIGATORIAMENTE quando mencionar um gasto.',
          parameters: {
            type: 'OBJECT',
            properties: {
              amount:      { type: 'NUMBER', description: 'Valor numérico em reais. OBRIGATORIAMENTE um número, nunca uma string. Ex: 50.0, 245.0' },
              category:    { type: 'STRING', description: 'Categoria: fuel, maintenance, car_wash, toll, parking, documentation, insurance, fine, meals, phone, other' },
              date:        { type: 'STRING', description: 'Data no formato YYYY-MM-DD. Use hoje se não especificado.' },
              vendor:      { type: 'STRING', description: 'Estabelecimento ou fornecedor' },
              description: { type: 'STRING', description: 'Observação adicional opcional. Não usar para repetir a categoria.' }
            },
            required: ['amount', 'category', 'date']
          }
        }
      end
    end
  end
end
