module Plans
  class Subscription
    BILLING = {
      'monthly' => { price_key: :price_month, advance: ->(start) { start >> 1 } },
      'yearly'  => { price_key: :price_year, advance: ->(start) { start >> 12 } }
    }.freeze

    def initialize(user)
      @user = user
    end

    def billing = @user.plan_billing

    def price = Catalog::PLANS.fetch(:pro).fetch(billing_rule.fetch(:price_key))

    def features = Catalog::PLANS.fetch(:pro).fetch(:features)

    def next_charge_on = billing_rule.fetch(:advance).call(@user.plan_since.to_date)

    private

    def billing_rule = BILLING.fetch(billing)
  end
end
