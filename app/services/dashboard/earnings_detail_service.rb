module Dashboard
  class EarningsDetailService < BaseDetailService
    private

    def base_scope
      @user.earnings
    end

    def empty_scope
      Earning.none
    end

    def list_key
      :earnings
    end

    def by_month_key
      :earnings_by_month
    end
  end
end
