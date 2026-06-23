module Chat
  class GoalPersister
    def persist(payload, user:)
      result = Goals::Creator.new(payload, user: user).call

      if result.success?
        PersistedResult.success(record: result.goal, action: 'create_goal')
      else
        PersistedResult.failure(errors: result.goal.errors.full_messages)
      end
    end
  end
end
