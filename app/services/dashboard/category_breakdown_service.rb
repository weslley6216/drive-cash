module Dashboard
  class CategoryBreakdownService
    CATEGORY_META = {
      'fuel'          => { color: '#dc2626', icon: PhlexIcons::Lucide::Fuel },
      'maintenance'   => { color: '#f97316', icon: PhlexIcons::Lucide::Wrench },
      'car_wash'      => { color: '#0ea5e9', icon: PhlexIcons::Lucide::Droplet },
      'toll'          => { color: '#a855f7', icon: PhlexIcons::Lucide::Coins },
      'parking'       => { color: '#6366f1', icon: PhlexIcons::Lucide::SquareParking },
      'documentation' => { color: '#0d9488', icon: PhlexIcons::Lucide::FileText },
      'insurance'     => { color: '#2563eb', icon: PhlexIcons::Lucide::ShieldCheck },
      'fine'          => { color: '#b91c1c', icon: PhlexIcons::Lucide::TriangleAlert },
      'meals'         => { color: '#16a34a', icon: PhlexIcons::Lucide::Utensils },
      'phone'         => { color: '#7c3aed', icon: PhlexIcons::Lucide::Smartphone }
    }.freeze

    DEFAULT_COLOR = '#94a3b8'
    DEFAULT_ICON  = PhlexIcons::Lucide::Package

    def initialize(year:, month: nil, limit: 4, user: Current.user)
      @year = year
      @month = month
      @limit = limit
      @user = user
    end

    def call
      scope = @user.expenses.paid_in_period(year, month)

      total = scope.sum(:amount).to_f
      return [] if total.zero?

      scope.group(:category)
           .sum(:amount)
           .sort_by { |_category, amount| -amount }
           .first(@limit)
           .map { |category, amount| build_row(category, amount, total) }
    end

    private

    attr_reader :year, :month, :limit

    def build_row(category, amount, total)
      meta = CATEGORY_META[category] || {}
      {
        id: category,
        label: I18n.t("activerecord.attributes.expense.categories.#{category}"),
        amount: amount,
        percent: (amount.to_f / total * 100).round(1),
        color: meta[:color] || DEFAULT_COLOR,
        icon: meta[:icon]  || DEFAULT_ICON
      }
    end
  end
end
