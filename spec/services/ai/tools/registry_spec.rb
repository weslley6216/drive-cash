require 'rails_helper'

RSpec.describe Ai::Tools::Registry do
  EXPECTED_QUERY_KINDS = {
    'summary'            => [Ai::Readers::Summary, Chat::Answers::Summary],
    'vendor_efficiency'  => [Ai::Readers::VendorEfficiency, Chat::Answers::VendorEfficiency],
    'best_day'           => [Ai::Readers::BestDay, Chat::Answers::BestDay],
    'worst_platform'     => [Ai::Readers::WorstPlatform, Chat::Answers::WorstPlatform],
    'category_spike'     => [Ai::Readers::CategorySpike, Chat::Answers::CategorySpike],
    'margin_drop'        => [Ai::Readers::MarginDrop, Chat::Answers::MarginDrop],
    'per_km'             => [Ai::Readers::PerKm, Chat::Answers::PerKm],
    'per_trip'           => [Ai::Readers::PerTrip, Chat::Answers::PerTrip],
    'tank_balance'       => [Ai::Readers::TankBalance, Chat::Answers::TankBalance],
    'last_full_tank'     => [Ai::Readers::LastFullTank, Chat::Answers::LastFullTank],
    'goal_progress'      => [Ai::Readers::GoalProgress, Chat::Answers::GoalProgress],
    'platform_breakdown' => [Ai::Readers::PlatformBreakdown, Chat::Answers::PlatformBreakdown],
    'best_month'         => [Ai::Readers::BestMonth, Chat::Answers::BestMonth],
    'unpaid_expenses'    => [Ai::Readers::UnpaidExpenses, Chat::Answers::UnpaidExpenses],
    'maintenance_status' => [Ai::Readers::MaintenanceStatus, Chat::Answers::MaintenanceStatus],
    'last_maintenance'   => [Ai::Readers::LastMaintenance, Chat::Answers::LastMaintenance],
    'history_search'     => [Ai::Readers::HistorySearch, Chat::Answers::HistorySearch]
  }.freeze

  describe '.declarations' do
    it 'exposes 5 tool declarations (4 create + 1 query)' do
      names = described_class.declarations.map { |declaration| declaration[:name] }

      expect(names).to contain_exactly(
        'create_earning', 'create_expense', 'create_goal', 'update_maintenance', 'query'
      )
    end

    it 'embeds the kind enum inside the query declaration' do
      query_declaration = described_class.declarations.find { |declaration| declaration[:name] == 'query' }

      expect(query_declaration[:parameters][:properties][:type][:enum]).to match_array(EXPECTED_QUERY_KINDS.keys)
    end
  end

  describe '.find' do
    it 'resolves the consolidated query tool' do
      tool = described_class.find('query')

      expect(tool.kind).to eq(:query)
      expect(tool.declaration[:name]).to eq('query')
    end

    it 'resolves create_expense wiring' do
      tool = described_class.find('create_expense')

      expect(tool.kind).to eq(:create)
      expect(tool.persister).to eq(Chat::ExpensePersister)
      expect(tool.summary_presenter).to eq(Chat::Summaries::Expense)
      expect(tool.confirm_key).to eq('chat.confirm.success_expense')
      expect(tool.requires_amount).to be(true)
    end

    it 'resolves create_earning wiring' do
      tool = described_class.find('create_earning')

      expect(tool.persister).to eq(Chat::EarningPersister)
      expect(tool.summary_presenter).to eq(Chat::Summaries::Earning)
      expect(tool.confirm_key).to eq('chat.confirm.success_earning')
    end

    it 'resolves create_goal without amount requirement' do
      tool = described_class.find('create_goal')

      expect(tool.kind).to eq(:create)
      expect(tool.requires_amount).to be(false)
      expect(tool.persister).to eq(Chat::GoalPersister)
    end

    it 'resolves update_maintenance without amount requirement' do
      tool = described_class.find('update_maintenance')

      expect(tool.kind).to eq(:create)
      expect(tool.requires_amount).to be(false)
      expect(tool.persister).to eq(Chat::MaintenanceUpdater)
    end

    it 'no longer resolves the legacy per-kind names' do
      expect(described_class.find('query_summary')).to be_nil
      expect(described_class.find('query_history_search')).to be_nil
    end

    it 'returns nil for an unknown action' do
      expect(described_class.find('unknown_action')).to be_nil
    end
  end

  describe '.query_kind' do
    it 'resolves reader and answer_presenter for each registered kind' do
      EXPECTED_QUERY_KINDS.each do |kind, (reader, presenter)|
        resolved = described_class.query_kind(kind)

        expect(resolved.reader).to eq(reader), "kind=#{kind}: wrong reader"
        expect(resolved.answer_presenter).to eq(presenter), "kind=#{kind}: wrong presenter"
      end
    end

    it 'returns nil for an unknown kind' do
      expect(described_class.query_kind('not_a_kind')).to be_nil
    end
  end
end
