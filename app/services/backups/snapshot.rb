module Backups
  class Snapshot
    Entry = Data.define(:date, :amount)
    Payload = Data.define(:rows, :earnings, :expenses)

    def self.call(user:)
      new(user: user).call
    end

    def initialize(user:)
      @user = user
      @vehicle = user.vehicle
    end

    def call
      earnings = @user.earnings.order(:date, :id).to_a
      expenses = @user.expenses.order(:date, :id).to_a

      Payload.new(
        rows:     {
          earnings:     earnings.map { |earning| earning_row(earning) },
          expenses:     expenses.map { |expense| expense_row(expense) },
          refuelings:   refuelings.map { |refueling| refueling_row(refueling) },
          maintenances: maintenances.map { |maintenance| maintenance_row(maintenance) },
          goals:        goals.map { |goal| goal_row(goal) }
        },
        earnings: earnings.map { |earning| Entry.new(date: earning.date, amount: earning.amount.to_f) },
        expenses: expenses.select(&:paid).map { |expense| Entry.new(date: expense.date, amount: expense.amount.to_f) }
      )
    end

    private

    def refuelings
      @vehicle ? @vehicle.refuelings.order(:date, :id).to_a : []
    end

    def maintenances
      @vehicle ? @vehicle.maintenances.order(:category).to_a : []
    end

    def goals
      @user.goals.order(:period_start, :id).to_a
    end

    def earning_row(earning)
      [
        earning.date.iso8601,
        Earning.human_enum_name(:platform, earning.platform),
        earning.amount.to_f,
        earning.trips_count,
        earning.notes,
        earning.created_at.in_time_zone.strftime('%Y-%m-%d %H:%M:%S')
      ]
    end

    def expense_row(expense)
      [
        expense.date.iso8601,
        Expense.human_enum_name(:category, expense.category),
        expense.amount.to_f,
        expense.vendor,
        expense.description,
        boolean_label(expense.paid),
        expense.installment_number,
        expense.installment_count
      ]
    end

    def refueling_row(refueling)
      [
        refueling.date.iso8601,
        refueling.vendor,
        refueling.liters&.to_f,
        refueling.price_per_liter&.to_f,
        refueling.total_amount.to_f,
        refueling.odometer_km,
        boolean_label(refueling.full_tank)
      ]
    end

    def maintenance_row(maintenance)
      [
        I18n.t("vehicle.maintenances.catalog.#{maintenance.category}"),
        maintenance.interval_km,
        maintenance.last_done_km,
        maintenance.estimated_cost&.to_f
      ]
    end

    def goal_row(goal)
      [
        I18n.t("backups.goal_kinds.#{goal.kind}"),
        I18n.t("backups.goal_metrics.#{goal.metric}"),
        goal.period_start.iso8601,
        goal.period_end.iso8601,
        goal.target_amount.to_f
      ]
    end

    def boolean_label(value)
      I18n.t("backups.boolean.#{value}")
    end
  end
end
