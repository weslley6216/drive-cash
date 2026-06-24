module Ai
  module Tools
    class Registry
      Tool = Data.define(
        :name, :declaration, :kind,
        :persister, :summary_presenter, :confirm_key, :requires_amount,
        :reader, :answer_presenter
      ) do
        def query? = kind == :query

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
        ),
        Tool.query_tool(
          name:             'query_per_km',
          declaration:      QueryPerKm.declaration,
          reader:           Ai::Readers::PerKm,
          answer_presenter: Chat::Answers::PerKm
        ),
        Tool.query_tool(
          name:             'query_per_trip',
          declaration:      QueryPerTrip.declaration,
          reader:           Ai::Readers::PerTrip,
          answer_presenter: Chat::Answers::PerTrip
        ),
        Tool.query_tool(
          name:             'query_tank_balance',
          declaration:      QueryTankBalance.declaration,
          reader:           Ai::Readers::TankBalance,
          answer_presenter: Chat::Answers::TankBalance
        ),
        Tool.query_tool(
          name:             'query_last_full_tank',
          declaration:      QueryLastFullTank.declaration,
          reader:           Ai::Readers::LastFullTank,
          answer_presenter: Chat::Answers::LastFullTank
        ),
        Tool.query_tool(
          name:             'query_goal_progress',
          declaration:      QueryGoalProgress.declaration,
          reader:           Ai::Readers::GoalProgress,
          answer_presenter: Chat::Answers::GoalProgress
        ),
        Tool.query_tool(
          name:             'query_platform_breakdown',
          declaration:      QueryPlatformBreakdown.declaration,
          reader:           Ai::Readers::PlatformBreakdown,
          answer_presenter: Chat::Answers::PlatformBreakdown
        ),
        Tool.query_tool(
          name:             'query_best_month',
          declaration:      QueryBestMonth.declaration,
          reader:           Ai::Readers::BestMonth,
          answer_presenter: Chat::Answers::BestMonth
        ),
        Tool.query_tool(
          name:             'query_unpaid_expenses',
          declaration:      QueryUnpaidExpenses.declaration,
          reader:           Ai::Readers::UnpaidExpenses,
          answer_presenter: Chat::Answers::UnpaidExpenses
        ),
        Tool.query_tool(
          name:             'query_maintenance_status',
          declaration:      QueryMaintenanceStatus.declaration,
          reader:           Ai::Readers::MaintenanceStatus,
          answer_presenter: Chat::Answers::MaintenanceStatus
        ),
        Tool.query_tool(
          name:             'query_last_maintenance',
          declaration:      QueryLastMaintenance.declaration,
          reader:           Ai::Readers::LastMaintenance,
          answer_presenter: Chat::Answers::LastMaintenance
        ),
        Tool.query_tool(
          name:             'query_history_search',
          declaration:      QueryHistorySearch.declaration,
          reader:           Ai::Readers::HistorySearch,
          answer_presenter: Chat::Answers::HistorySearch
        ),
        Tool.create_tool(
          name:              'create_goal',
          declaration:       CreateGoal.declaration,
          persister:         Chat::GoalPersister,
          summary_presenter: Chat::Summaries::Goal,
          confirm_key:       'chat.confirm.success_goal',
          requires_amount:   false
        ),
        Tool.create_tool(
          name:              'update_maintenance',
          declaration:       UpdateMaintenance.declaration,
          persister:         Chat::MaintenanceUpdater,
          summary_presenter: Chat::Summaries::Maintenance,
          confirm_key:       'chat.confirm.success_maintenance',
          requires_amount:   false
        )
      ].freeze

      def self.all = TOOLS
      def self.declarations = TOOLS.map(&:declaration)
      def self.find(name) = TOOLS.find { |tool| tool.name == name }
    end
  end
end
