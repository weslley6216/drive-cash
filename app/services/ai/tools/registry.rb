module Ai
  module Tools
    class Registry
      Tool = Data.define(:name, :declaration, :persister, :summary_presenter, :confirm_key, :requires_amount)

      TOOLS = [
        Tool.new(
          name:              'create_earning',
          declaration:       CreateEarning.declaration,
          persister:         Chat::EarningPersister,
          summary_presenter: Chat::Summaries::Earning,
          confirm_key:       'chat.confirm.success_earning',
          requires_amount:   true
        ),
        Tool.new(
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
