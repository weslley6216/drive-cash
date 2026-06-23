module Ai
  module Tools
    module QueryGoalProgress
      def self.declaration
        {
          name:        'query_goal_progress',
          description: 'Informa o progresso das metas financeiras do motorista.',
          parameters:  { type: 'OBJECT', properties: {}, required: [] }
        }
      end
    end
  end
end
