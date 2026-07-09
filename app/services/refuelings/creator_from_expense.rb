module Refuelings
  class CreatorFromExpense
    Result = Data.define(:success?, :refueling)

    def self.call(expense:, liters:, odometer_km:, full_tank: true)
      new(expense: expense, liters: liters, odometer_km: odometer_km, full_tank: full_tank).call
    end

    def initialize(expense:, liters:, odometer_km:, full_tank:)
      @expense = expense
      @liters = liters
      @odometer_km = odometer_km
      @full_tank = full_tank
    end

    def call
      return Result.new(success?: true, refueling: nil) unless eligible?

      refueling = build_refueling
      if refueling.save
        Vehicles::OdometerSync.new(vehicle: refueling.vehicle, reading_km: refueling.odometer_km, on: refueling.date).call
        Result.new(success?: true, refueling: refueling)
      else
        Result.new(success?: false, refueling: refueling)
      end
    end

    private

    def build_refueling
      @expense.user.vehicle.refuelings.new(
        expense:      @expense,
        date:         @expense.date,
        vendor:       @expense.vendor,
        liters:       @liters,
        odometer_km:  @odometer_km.to_i,
        total_amount: @expense.amount,
        full_tank:    ActiveModel::Type::Boolean.new.cast(@full_tank)
      )
    end

    def eligible?
      return false unless @expense.category_fuel?
      return false if @liters.to_s.strip.empty?
      return false if @odometer_km.to_s.strip.empty?
      return false unless @expense.user.vehicle

      true
    end
  end
end
