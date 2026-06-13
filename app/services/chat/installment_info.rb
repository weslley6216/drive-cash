module Chat
  class InstallmentInfo
    def initialize(params)
      @params = params || {}
    end

    def present?
      count >= 2 && Expense::INSTALLMENT_PERIODS.include?(period)
    end

    def count
      raw_value = @params['installments'] || @params['installment_count']
      raw_value.respond_to?(:to_i) ? raw_value.to_i : 0
    end

    def period
      (@params['installments_period'].presence || @params['installment_period']).to_s
    end
  end
end
