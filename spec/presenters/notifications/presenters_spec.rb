require 'rails_helper'

RSpec.describe Notifications::Presenters do
  def present(kind, data)
    described_class.present(build_stubbed(:notification, kind: kind, data: data))
  end

  describe 'maintenance_due' do
    let(:data) do
      { 'maintenance_id' => 1, 'status' => 'overdue', 'category' => 'oil_change',
        'km_until' => -412, 'interval_km' => 5_000 }
    end

    it 'renders the overdue title with the catalog label and a gender-neutral wording' do
      row = present('maintenance_due', data)

      expect(row.title).to eq('Manutenção vencida: Troca de óleo')
    end

    it 'renders the overdue body with the absolute km past the interval' do
      row = present('maintenance_due', data)

      expect(row.body).to eq('Passou 412 km do intervalo. Agende pra evitar dano ao motor.')
    end

    it 'renders the soon title and body with a delimited interval' do
      row = present('maintenance_due', data.merge('status' => 'soon', 'km_until' => 600,
                                                  'interval_km' => 10_000, 'category' => 'tire_rotation'))

      expect(row.title).to eq('Rodízio de pneus em breve')
      expect(row.body).to eq('Faltam ~600 km pro intervalo de 10.000 km.')
    end

    it 'paints overdue as danger and soon as warning' do
      expect(present('maintenance_due', data).palette_key).to eq(:danger)
      expect(present('maintenance_due', data.merge('status' => 'soon')).palette_key).to eq(:warning)
    end

    it 'uses the wrench icon' do
      expect(present('maintenance_due', data).icon).to eq(PhlexIcons::Lucide::Wrench)
    end

    it 'links to the vehicle highlighted on the overdue item, with an inline mark-done action in the modal frame' do
      row = present('maintenance_due', data)

      expect(row.path).to eq('/vehicle?highlight=maintenance_1')
      expect(row.frame).to eq('_top')
      expect(row.inline_action.label).to eq('Marcar como feita')
      expect(row.inline_action.path).to eq('/maintenances/1/mark_done/new')
      expect(row.inline_action.frame).to eq('modal')
    end
  end

  describe 'goal_reached' do
    it 'renders the month name and the reached amount in BRL' do
      row = present('goal_reached', { 'goal_id' => 1, 'month' => '2026-07-01', 'current' => 1_200.0 })

      expect(row.title).to eq('Meta batida! 🎯')
      expect(row.body).to eq('Você bateu a meta de Julho com R$ 1.200,00.')
      expect(row.palette_key).to eq(:success)
      expect(row.icon).to eq(PhlexIcons::Lucide::Target)
    end

    it 'links to goals with no inline action' do
      row = present('goal_reached', { 'goal_id' => 1, 'month' => '2026-07-01', 'current' => 1_200.0 })

      expect(row.path).to eq('/goals')
      expect(row.inline_action).to be_nil
    end
  end

  describe 'tank_low' do
    it 'renders the static copy with the danger palette' do
      row = present('tank_low', { 'status' => 'negative', 'balance' => -80.0, 'last_fill_id' => 1 })

      expect(row.title).to eq('Tanque no vermelho')
      expect(row.body).to eq('Você rodou além do último tanque. Registre um abastecimento.')
      expect(row.palette_key).to eq(:danger)
      expect(row.icon).to eq(PhlexIcons::Lucide::Fuel)
    end

    it 'opens the refueling form in the modal frame, with an inline refuel action' do
      row = present('tank_low', { 'status' => 'negative', 'balance' => -80.0, 'last_fill_id' => 1 })

      expect(row.path).to eq('/refuelings/new')
      expect(row.frame).to eq('modal')
      expect(row.inline_action.label).to eq('Abastecer')
      expect(row.inline_action.path).to eq('/refuelings/new')
      expect(row.inline_action.frame).to eq('modal')
    end
  end

  describe 'weekly_summary' do
    it 'renders profit in BRL and pluralised trips' do
      row = present('weekly_summary', { 'week_start' => '2026-07-06', 'profit' => 987.4, 'trips' => 32 })

      expect(row.body).to eq('Líquido de R$ 987,40 · 32 corridas.')
      expect(row.palette_key).to eq(:info)
      expect(row.icon).to eq(PhlexIcons::Lucide::ChartColumn)
    end

    it 'links to the analysis of the month the summarized week falls in' do
      row = present('weekly_summary', { 'week_start' => '2026-06-29', 'profit' => 987.4, 'trips' => 32 })

      expect(row.path).to eq('/analysis?month=6&year=2026')
    end
  end

  describe 'log_reminder' do
    it 'renders the static copy with the neutral palette' do
      row = present('log_reminder', { 'date' => '2026-07-14' })

      expect(row.title).to eq('Registre o seu dia')
      expect(row.palette_key).to eq(:neutral)
      expect(row.icon).to eq(PhlexIcons::Lucide::Calendar)
    end

    it 'links to a new record dated the day before the reminder' do
      row = present('log_reminder', { 'date' => '2026-07-14' })

      expect(row.path).to eq('/records/new?date=2026-07-13')
    end
  end

  it 'carries the notification through so the row can read id and read state' do
    notification = build_stubbed(:notification, kind: 'log_reminder', data: { 'date' => '2026-07-14' })

    expect(described_class.present(notification).notification).to eq(notification)
  end

  describe '#destination' do
    it 'uses the inline path when tapped inline' do
      row = present('maintenance_due', { 'maintenance_id' => 1, 'status' => 'overdue', 'category' => 'oil_change',
                                         'km_until' => -412, 'interval_km' => 5_000 })

      expect(row.destination('inline')).to eq('/maintenances/1/mark_done/new')
    end

    it 'falls back to the row path when the kind has no inline action' do
      row = present('goal_reached', { 'goal_id' => 1, 'month' => '2026-07-01', 'current' => 1_200.0 })

      expect(row.destination('inline')).to eq('/goals')
    end

    it 'uses the row path when not tapped inline' do
      row = present('maintenance_due', { 'maintenance_id' => 1, 'status' => 'overdue', 'category' => 'oil_change',
                                         'km_until' => -412, 'interval_km' => 5_000 })

      expect(row.destination(nil)).to eq('/vehicle?highlight=maintenance_1')
    end
  end
end
