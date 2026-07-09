module Refuelings
  class Updater
    include SyncsOdometer

    def self.call(refueling:, params:)
      new(refueling: refueling, params: params).call
    end

    def initialize(refueling:, params:)
      @refueling = refueling
      @params = params
    end

    def call
      Refueling.transaction do
        if @refueling.update(@params)
          sync_odometer(@refueling)
          Result.new(success?: true, refueling: @refueling)
        else
          Result.new(success?: false, refueling: @refueling)
        end
      end
    end
  end
end
