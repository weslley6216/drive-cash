module Chat
  class RecordPersister
    class NullPersister
      def persist(_payload, **)
        PersistedResult.failure(errors: [I18n.t('chat.errors.unknown_action')])
      end
    end

    def self.for(action)
      tool = Ai::Tools::Registry.find(action)
      return NullPersister.new unless tool

      tool.persister.new
    end
  end
end
