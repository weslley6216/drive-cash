require 'rails_helper'

RSpec.describe Notifications::Presenters do
  describe 'maintenance_due' do
    let(:data) do
      { 'maintenance_id' => 1, 'status' => 'overdue', 'category' => 'oil_change',
        'km_until' => -412, 'interval_km' => 5_000 }
    end

    it 'renders the overdue title with the catalog label and a gender-neutral wording' do
      notification = build_stubbed(:notification, kind: 'maintenance_due', data: data)

      row = described_class.present(notification)

      expect(row.title).to eq('Manutenção vencida: Troca de óleo')
    end

    it 'renders the overdue body with the absolute km past the interval' do
      notification = build_stubbed(:notification, kind: 'maintenance_due', data: data)

      row = described_class.present(notification)

      expect(row.body).to eq('Passou 412 km do intervalo. Agende pra evitar dano ao motor.')
    end

    it 'renders the soon title and body with a delimited interval' do
      notification = build_stubbed(:notification, kind: 'maintenance_due',
                                                  data: data.merge('status' => 'soon', 'km_until' => 600,
                                                                   'interval_km' => 10_000, 'category' => 'tire_rotation'))

      row = described_class.present(notification)

      expect(row.title).to eq('Rodízio de pneus em breve')
      expect(row.body).to eq('Faltam ~600 km pro intervalo de 10.000 km.')
    end

    it 'paints overdue as danger and soon as warning' do
      overdue_notification = build_stubbed(:notification, kind: 'maintenance_due', data: data)
      soon_notification = build_stubbed(:notification, kind: 'maintenance_due', data: data.merge('status' => 'soon'))

      overdue = described_class.present(overdue_notification)
      soon = described_class.present(soon_notification)

      expect(overdue.palette_key).to eq(:danger)
      expect(soon.palette_key).to eq(:warning)
    end

    it 'uses the wrench icon' do
      notification = build_stubbed(:notification, kind: 'maintenance_due', data: data)

      row = described_class.present(notification)

      expect(row.icon).to eq(PhlexIcons::Lucide::Wrench)
    end

    it 'links to the vehicle highlighted on the overdue item, with an inline mark-done action in the modal frame' do
      notification = build_stubbed(:notification, kind: 'maintenance_due', data: data)

      row = described_class.present(notification)

      expect(row.path).to eq('/vehicle?highlight=maintenance_1')
      expect(row.frame).to eq('_top')
      expect(row.inline_action.label).to eq('Marcar como feita')
      expect(row.inline_action.path).to eq('/maintenances/1/mark_done/new')
      expect(row.inline_action.frame).to eq('modal')
    end
  end

  describe 'goal_reached' do
    let(:data) do
      { 'goal_id' => 1, 'period_start' => '2026-07-01', 'kind' => 'monthly', 'metric' => 'profit',
        'target' => 1_000.0, 'current' => 1_200.0 }
    end

    it 'titles the row by the goal kind and names the period with the reached amount in BRL' do
      notification = build_stubbed(:notification, kind: 'goal_reached', data: data)

      row = described_class.present(notification)

      expect(row.title).to eq('Meta mensal batida! 🎯')
      expect(row.body).to eq("Você bateu a meta de julho com R$\u00A01.200,00.")
      expect(row.palette_key).to eq(:success)
      expect(row.icon).to eq(PhlexIcons::Lucide::Target)
    end

    it 'names a weekly goal by its week and an annual goal by its year' do
      weekly_notification = build_stubbed(:notification, kind: 'goal_reached',
                                                         data: data.merge('kind' => 'weekly', 'period_start' => '2026-07-06'))
      annual_notification = build_stubbed(:notification, kind: 'goal_reached',
                                                         data: data.merge('kind' => 'annual', 'period_start' => '2026-01-01'))

      weekly = described_class.present(weekly_notification)
      annual = described_class.present(annual_notification)

      expect(weekly.title).to eq('Meta semanal batida! 🎯')
      expect(weekly.body).to eq("Você bateu a meta de 06/jul a 12/jul com R$\u00A01.200,00.")
      expect(annual.title).to eq('Meta anual batida! 🎯')
      expect(annual.body).to eq("Você bateu a meta de 2026 com R$\u00A01.200,00.")
    end

    it 'links to the outcome of the goal period with no inline action' do
      notification = build_stubbed(:notification, kind: 'goal_reached', data: data)

      row = described_class.present(notification)

      expect(row.path).to eq('/goals/1/outcomes/2026-07-01')
      expect(row.inline_action).to be_nil
    end
  end

  describe 'goal_missed' do
    let(:data) do
      { 'goal_id' => 1, 'period_start' => '2026-07-06', 'kind' => 'weekly', 'metric' => 'profit',
        'target' => 1_100.0, 'current' => 990.0 }
    end

    it 'tells a near miss of the week with the percent and the amounts in BRL' do
      notification = build_stubbed(:notification, kind: 'goal_missed', data: data)

      row = described_class.present(notification)

      expect(row.title).to eq('Meta da semana: faltou pouco')
      expect(row.body).to eq("Você chegou a 90% (R$\u00A0990,00 de R$\u00A01.100,00).")
      expect(row.palette_key).to eq(:attention)
      expect(row.icon).to eq(PhlexIcons::Lucide::Target)
    end

    it 'closes a goal under eighty percent without the near miss wording' do
      notification = build_stubbed(:notification, kind: 'goal_missed', data: data.merge('current' => 700.0))

      row = described_class.present(notification)

      expect(row.title).to eq('Meta da semana encerrada')
      expect(row.body).to eq("Você chegou a 63% (R$\u00A0700,00 de R$\u00A01.100,00).")
    end

    it 'names a monthly goal by its month and an annual goal by its year' do
      monthly_notification = build_stubbed(:notification, kind: 'goal_missed',
                                                          data: data.merge('kind' => 'monthly', 'period_start' => '2026-07-01'))
      annual_notification = build_stubbed(:notification, kind: 'goal_missed',
                                                         data: data.merge('kind' => 'annual', 'period_start' => '2026-01-01', 'current' => 500.0))

      monthly = described_class.present(monthly_notification)
      annual = described_class.present(annual_notification)

      expect(monthly.title).to eq('Meta de julho: faltou pouco')
      expect(annual.title).to eq('Meta de 2026 encerrada')
    end

    it 'links to the outcome of the goal period with no inline action' do
      notification = build_stubbed(:notification, kind: 'goal_missed', data: data)

      row = described_class.present(notification)

      expect(row.path).to eq('/goals/1/outcomes/2026-07-06')
      expect(row.inline_action).to be_nil
    end
  end

  describe 'tank_low' do
    it 'renders the static copy with the danger palette' do
      notification = build_stubbed(:notification, kind: 'tank_low',
                                                  data: { 'status' => 'negative', 'balance' => -80.0, 'last_fill_id' => 1 })

      row = described_class.present(notification)

      expect(row.title).to eq('Tanque no vermelho')
      expect(row.body).to eq('Você rodou além do último tanque. Registre um abastecimento.')
      expect(row.palette_key).to eq(:danger)
      expect(row.icon).to eq(PhlexIcons::Lucide::Fuel)
    end

    it 'links to the vehicle with the tank card highlighted, keeping the inline refuel action in the modal frame' do
      notification = build_stubbed(:notification, kind: 'tank_low',
                                                  data: { 'status' => 'negative', 'balance' => -80.0, 'last_fill_id' => 1 })

      row = described_class.present(notification)

      expect(row.path).to eq('/vehicle?highlight=vehicle_tank')
      expect(row.frame).to eq('_top')
      expect(row.inline_action.label).to eq('Abastecer')
      expect(row.inline_action.path).to eq('/refuelings/new')
      expect(row.inline_action.frame).to eq('modal')
    end
  end

  describe 'weekly_summary' do
    it 'renders profit in BRL and pluralised trips' do
      notification = build_stubbed(:notification, kind: 'weekly_summary',
                                                  data: { 'week_start' => '2026-07-06', 'profit' => 987.4, 'trips' => 32 })

      row = described_class.present(notification)

      expect(row.body).to eq("Líquido de R$\u00A0987,40 · 32 corridas.")
      expect(row.palette_key).to eq(:info)
      expect(row.icon).to eq(PhlexIcons::Lucide::ChartColumn)
    end

    it 'links to the summary screen of the week' do
      notification = build_stubbed(:notification, kind: 'weekly_summary',
                                                  data: { 'week_start' => '2026-07-06', 'profit' => 987.4, 'trips' => 32 })

      row = described_class.present(notification)

      expect(row.path).to eq('/weekly_summaries/2026-07-06')
    end
  end

  describe 'log_reminder' do
    it 'renders the static copy with the neutral palette' do
      notification = build_stubbed(:notification, kind: 'log_reminder', data: { 'date' => '2026-07-14' })

      row = described_class.present(notification)

      expect(row.title).to eq('Registre o seu dia')
      expect(row.palette_key).to eq(:neutral)
      expect(row.icon).to eq(PhlexIcons::Lucide::Calendar)
    end

    it 'links to the history focused on the empty day before the reminder' do
      notification = build_stubbed(:notification, kind: 'log_reminder', data: { 'date' => '2026-07-14' })

      row = described_class.present(notification)

      expect(row.path).to eq('/history?focus_day=2026-07-13&highlight=day-2026-07-13')
      expect(row.frame).to eq('_top')
    end

    it 'offers an inline Lançar ontem to a new record on the empty day when the reminder is from today' do
      travel_to Date.new(2026, 7, 14)

      notification = build_stubbed(:notification, kind: 'log_reminder', data: { 'date' => '2026-07-14' })

      row = described_class.present(notification)

      expect(row.inline_action.label).to eq('Lançar ontem')
      expect(row.inline_action.path).to eq('/records/new?date=2026-07-13')
      expect(row.inline_action.frame).to eq('_top')
    end

    it 'offers an inline action with the empty day when the reminder is older' do
      travel_to Date.new(2026, 7, 20)

      notification = build_stubbed(:notification, kind: 'log_reminder', data: { 'date' => '2026-07-14' })

      row = described_class.present(notification)

      expect(row.inline_action.label).to eq('Lançar 13/07')
    end
  end

  describe 'row destinations' do
    sample_data = {
      'maintenance_due' => { 'maintenance_id' => 1, 'status' => 'overdue', 'category' => 'oil_change',
                             'km_until' => -412, 'interval_km' => 5_000 },
      'tank_low'        => { 'status' => 'negative', 'balance' => -80.0, 'last_fill_id' => 1 },
      'goal_reached'    => { 'goal_id' => 1, 'period_start' => '2026-07-01', 'kind' => 'monthly',
                             'metric' => 'profit', 'target' => 1_000.0, 'current' => 1_200.0 },
      'goal_missed'     => { 'goal_id' => 1, 'period_start' => '2026-07-06', 'kind' => 'weekly',
                             'metric' => 'profit', 'target' => 1_100.0, 'current' => 990.0 },
      'weekly_summary'  => { 'week_start' => '2026-07-06', 'profit' => 987.4, 'trips' => 32 },
      'log_reminder'    => { 'date' => '2026-07-14' }
    }

    Notifications::Registry::KINDS.each do |kind|
      it "opens a show screen in the top frame when tapping a #{kind} row" do
        notification = build_stubbed(:notification, kind: kind, data: sample_data.fetch(kind))

        row = described_class.present(notification)

        expect(row.frame).to eq('_top')
        expect(row.path).not_to match(%r{/(new|edit)(\?|/|\z)})
      end
    end
  end

  it 'carries the notification through so the row can read id and read state' do
    notification = build_stubbed(:notification, kind: 'log_reminder', data: { 'date' => '2026-07-14' })

    expect(described_class.present(notification).notification).to eq(notification)
  end

  describe '#destination' do
    it 'uses the inline path when tapped inline' do
      notification = build_stubbed(:notification, kind: 'maintenance_due', data: { 'maintenance_id' => 1, 'status' => 'overdue',
                                                                                   'category' => 'oil_change', 'km_until' => -412,
                                                                                   'interval_km' => 5_000 })

      row = described_class.present(notification)

      expect(row.destination('inline')).to eq('/maintenances/1/mark_done/new')
    end

    it 'falls back to the row path when the kind has no inline action' do
      notification = build_stubbed(:notification, kind: 'goal_reached', data: { 'goal_id' => 1, 'period_start' => '2026-07-01',
                                                                                'kind' => 'monthly', 'metric' => 'profit',
                                                                                'target' => 1_000.0, 'current' => 1_200.0 })

      row = described_class.present(notification)

      expect(row.destination('inline')).to eq('/goals/1/outcomes/2026-07-01')
    end

    it 'uses the row path when not tapped inline' do
      notification = build_stubbed(:notification, kind: 'maintenance_due', data: { 'maintenance_id' => 1, 'status' => 'overdue',
                                                                                   'category' => 'oil_change', 'km_until' => -412,
                                                                                   'interval_km' => 5_000 })

      row = described_class.present(notification)

      expect(row.destination(nil)).to eq('/vehicle?highlight=maintenance_1')
    end
  end
end
