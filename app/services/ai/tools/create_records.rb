module Ai
  module Tools
    module CreateRecords
      ACTIONS = %w[create_earning create_expense].freeze

      def self.declaration
        {
          name:        'create_records',
          description: 'Registra uma ou mais receitas/despesas do motorista numa única chamada. Use SEMPRE que precisar criar receita(s) e/ou despesa(s), mesmo um item só: um item em "records" por registro, na ordem em que o usuário mencionou.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              records: {
                type:        'ARRAY',
                description: 'Lista de registros a criar, um por item.',
                items:       {
                  type:       'OBJECT',
                  properties: {
                    action: {
                      type:        'STRING',
                      enum:        ACTIONS,
                      description: 'create_earning para receita, create_expense para despesa.'
                    },
                    **CreateEarning.declaration[:parameters][:properties],
                    **CreateExpense.declaration[:parameters][:properties]
                  },
                  required:   %w[action amount date]
                }
              }
            },
            required:   ['records']
          }
        }
      end

      def self.expand(calls)
        calls.flat_map do |call|
          next [call] unless call[:name] == 'create_records'

          Array(call[:input]['records']).map do |record|
            { name: record['action'], input: record.except('action').compact }
          end
        end
      end
    end
  end
end
