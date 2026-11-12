module Dashboard
  class HomeService
    def initialize(user:, year:, month:, reference_date:)
      @user = user
      @year = year
      @month = month
      @reference_date = reference_date
    end

    def call
      {
        totals:          StatsService.new(year: @year, month: @month, user: @user, ledger: ledger).call,
        recent_activity: RecentActivityService.new(year: @year, month: @month, user: @user).call,
        categories:      CategoryBreakdownService.new(year: @year, month: @month, user: @user, ledger: ledger).call,
        today:           TodayService.new(user: @user).call,
        monthly_goal:    monthly_goal
      }
    end

    private

    def ledger
      @ledger ||= YearLedger.new(user: @user, year: @year)
    end

    def monthly_goal
      return nil unless @reference_date

      Goals::ProgressService.new(user: @user, date: @reference_date, daily_totals: ledger.daily_totals).monthly
    end
  end
end
