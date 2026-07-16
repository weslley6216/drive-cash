module Plans
  class Subscription
    BILLING = {
      'monthly' => { price_key: :price_month, cycle_months: 1 },
      'yearly'  => { price_key: :price_year, cycle_months: 12 }
    }.freeze

    def initialize(user)
      @user = user
    end

    def billing = @user.plan_billing

    def price = pro.fetch(billing_rule.fetch(:price_key))

    def features = pro.fetch(:features)

    def next_charge_on
      cycles = 1
      cycles += 1 until charge_after(cycles) >= Date.current

      charge_after(cycles)
    end

    private

    def charge_after(cycles) = started_on >> (cycles * billing_rule.fetch(:cycle_months))

    def started_on = @user.plan_since.to_date

    def billing_rule = BILLING.fetch(billing)

    def pro = Catalog::PLANS.fetch(:pro)
  end
end
