module Ai
  module Tools
    module QueryHistorySearch
      def self.declaration
        {
          name:        'query_history_search',
          description: 'Busca no histórico de ganhos e despesas por um termo.',
          parameters:  {
            type:       'OBJECT',
            properties: {
              term: { type: 'STRING', description: 'Termo de busca (posto, plataforma, categoria, etc.)' }
            },
            required:   ['term']
          }
        }
      end
    end
  end
end
