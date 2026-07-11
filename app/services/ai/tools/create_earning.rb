module Ai
  module Tools
    module CreateEarning
      def self.declaration
        {
          name:        'create_earning',
          description: 'Registra uma receita do motorista. Use OBRIGATORIAMENTE quando mencionar valor ganho em corrida, entrega ou serviço.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              amount:      { type: 'NUMBER', description: 'Valor numérico em reais. OBRIGATORIAMENTE um número, nunca uma string. Ex: 50.0, 245.0' },
              platform:    { type: 'STRING', description: 'Plataforma utilizada: amazon, ifood, mercado_livre, nine_nine, rappi, shopee, uber, other' },
              date:        { type: 'STRING', description: 'Data no formato YYYY-MM-DD. Use hoje se não especificado.' },
              notes:       { type: 'STRING', description: 'Observações opcionais' },
              trips_count: { type: 'NUMBER', description: 'Quantidade de rotas feitas. Padrão 1 se não informado.' }
            },
            required:   ['amount', 'date', 'platform']
          }
        }
      end
    end
  end
end
