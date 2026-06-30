module Ai
  module Tools
    class Registry
      Tool = Data.define(
        :name, :declaration, :kind,
        :persister, :summary_presenter, :confirm_key, :requires_amount
      ) do
        def query? = kind == :query

        def self.create_tool(name:, declaration:, persister:, summary_presenter:, confirm_key:, requires_amount: false)
          new(
            name:, declaration:, kind: :create,
            persister:, summary_presenter:, confirm_key:, requires_amount:
          )
        end

        def self.query_tool(declaration:)
          new(
            name: 'query', declaration:, kind: :query,
            persister: nil, summary_presenter: nil, confirm_key: nil, requires_amount: false
          )
        end
      end

      QueryKind = Data.define(:reader, :answer_presenter)

      QUERY_KINDS = {
        'summary'            => QueryKind.new(reader: Ai::Readers::Summary, answer_presenter: Chat::Answers::Summary),
        'vendor_efficiency'  => QueryKind.new(reader: Ai::Readers::VendorEfficiency, answer_presenter: Chat::Answers::VendorEfficiency),
        'best_day'           => QueryKind.new(reader: Ai::Readers::BestDay, answer_presenter: Chat::Answers::BestDay),
        'worst_platform'     => QueryKind.new(reader: Ai::Readers::WorstPlatform, answer_presenter: Chat::Answers::WorstPlatform),
        'category_spike'     => QueryKind.new(reader: Ai::Readers::CategorySpike, answer_presenter: Chat::Answers::CategorySpike),
        'margin_drop'        => QueryKind.new(reader: Ai::Readers::MarginDrop, answer_presenter: Chat::Answers::MarginDrop),
        'per_km'             => QueryKind.new(reader: Ai::Readers::PerKm, answer_presenter: Chat::Answers::PerKm),
        'per_trip'           => QueryKind.new(reader: Ai::Readers::PerTrip, answer_presenter: Chat::Answers::PerTrip),
        'tank_balance'       => QueryKind.new(reader: Ai::Readers::TankBalance, answer_presenter: Chat::Answers::TankBalance),
        'last_full_tank'     => QueryKind.new(reader: Ai::Readers::LastFullTank, answer_presenter: Chat::Answers::LastFullTank),
        'goal_progress'      => QueryKind.new(reader: Ai::Readers::GoalProgress, answer_presenter: Chat::Answers::GoalProgress),
        'platform_breakdown' => QueryKind.new(reader: Ai::Readers::PlatformBreakdown, answer_presenter: Chat::Answers::PlatformBreakdown),
        'best_month'         => QueryKind.new(reader: Ai::Readers::BestMonth, answer_presenter: Chat::Answers::BestMonth),
        'unpaid_expenses'    => QueryKind.new(reader: Ai::Readers::UnpaidExpenses, answer_presenter: Chat::Answers::UnpaidExpenses),
        'maintenance_status' => QueryKind.new(reader: Ai::Readers::MaintenanceStatus, answer_presenter: Chat::Answers::MaintenanceStatus),
        'last_maintenance'   => QueryKind.new(reader: Ai::Readers::LastMaintenance, answer_presenter: Chat::Answers::LastMaintenance),
        'history_search'     => QueryKind.new(reader: Ai::Readers::HistorySearch, answer_presenter: Chat::Answers::HistorySearch)
      }.freeze

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
        ),
        Tool.query_tool(declaration: Query.declaration)
      ].freeze

      def self.all = TOOLS
      def self.declarations = TOOLS.map(&:declaration)
      def self.find(name) = TOOLS.find { |tool| tool.name == name }
      def self.query_kind(kind) = QUERY_KINDS[kind.to_s]
    end
  end
end
