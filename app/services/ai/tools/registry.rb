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
        ),
        Tool.query_tool(
          name:             'query_summary',
          declaration:      QuerySummary.declaration,
          reader:           Ai::Readers::Summary,
          answer_presenter: Chat::Answers::Summary
        ),
        Tool.query_tool(
          name:             'query_vendor_efficiency',
          declaration:      QueryVendorEfficiency.declaration,
          reader:           Ai::Readers::VendorEfficiency,
          answer_presenter: Chat::Answers::VendorEfficiency
        ),
        Tool.query_tool(
          name:             'query_best_day',
          declaration:      QueryBestDay.declaration,
          reader:           Ai::Readers::BestDay,
          answer_presenter: Chat::Answers::BestDay
        ),
        Tool.query_tool(
          name:             'query_worst_platform',
          declaration:      QueryWorstPlatform.declaration,
          reader:           Ai::Readers::WorstPlatform,
          answer_presenter: Chat::Answers::WorstPlatform
        ),
        Tool.query_tool(
          name:             'query_category_spike',
          declaration:      QueryCategorySpike.declaration,
          reader:           Ai::Readers::CategorySpike,
          answer_presenter: Chat::Answers::CategorySpike
        ),
        Tool.query_tool(
          name:             'query_margin_drop',
          declaration:      QueryMarginDrop.declaration,
          reader:           Ai::Readers::MarginDrop,
          answer_presenter: Chat::Answers::MarginDrop
        )
      ].freeze

      def self.all = TOOLS
      def self.declarations = TOOLS.map(&:declaration)
      def self.find(name) = TOOLS.find { |tool| tool.name == name }
    end
  end
end
