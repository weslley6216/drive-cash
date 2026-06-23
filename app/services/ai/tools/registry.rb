module Ai
  module Tools
    class Registry
      Tool = Data.define(
        :name, :declaration, :kind,
        :persister, :summary_presenter, :confirm_key, :requires_amount,
        :reader, :answer_presenter
      ) do
        def query? = kind == :query
        def create? = kind == :create

        def self.create_tool(name:, declaration:, persister:, summary_presenter:, confirm_key:, requires_amount: false)
          new(
            name:, declaration:, kind: :create,
            persister:, summary_presenter:, confirm_key:, requires_amount:,
            reader: nil, answer_presenter: nil
          )
        end

        def self.query_tool(name:, declaration:, reader:, answer_presenter:)
          new(
            name:, declaration:, kind: :query,
            persister: nil, summary_presenter: nil, confirm_key: nil, requires_amount: false,
            reader:, answer_presenter:
          )
        end
      end

      TOOLS = [
        Tool.create_tool(
          name:              'create_earning',
          declaration:       CreateEarning.declaration,
          persister:         Chat::EarningPersister,
          summary_presenter: Chat::Summaries::Earning,
          confirm_key:       'chat.confirm.success_earning',
          requires_amount:   true
        ),
        Tool.create_tool(
          name:              'create_expense',
          declaration:       CreateExpense.declaration,
          persister:         Chat::ExpensePersister,
          summary_presenter: Chat::Summaries::Expense,
          confirm_key:       'chat.confirm.success_expense',
          requires_amount:   true
        )
      ].freeze

      def self.all = TOOLS
      def self.declarations = TOOLS.map(&:declaration)
      def self.find(name) = TOOLS.find { |tool| tool.name == name }
    end
  end
end
