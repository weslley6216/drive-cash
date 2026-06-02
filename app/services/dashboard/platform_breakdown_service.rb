module Dashboard
  class PlatformBreakdownService
    PLATFORM_META = {
      'amazon'        => { color: '#ff9900' },
      'ifood'         => { color: '#ea1d2c' },
      'mercado_livre' => { color: '#ffe600' },
      'nine_nine'     => { color: '#fbbf24' },
      'rappi'         => { color: '#ff0033' },
      'shopee'        => { color: '#ee4d2d' },
      'uber'          => { color: '#000000' }
    }.freeze

    DEFAULT_COLOR = '#94a3b8'

    def initialize(year:, month: nil, limit: 5)
      @year = year
      @month = month
      @limit = limit
    end

    def call
      total = scope.sum(:amount).to_f
      return [] if total.zero?

      scope.group(:platform)
           .sum(:amount)
           .sort_by { |_platform, amount| -amount }
           .first(@limit)
           .map { |platform, amount| build_row(platform, amount, total) }
    end

    private

    attr_reader :year, :month, :limit

    def scope
      @scope ||= begin
        relation = Earning.for_year(year)
        relation = relation.for_month(month) if month
        relation
      end
    end

    def build_row(platform, amount, total)
      meta = PLATFORM_META[platform] || {}
      {
        id: platform,
        label: I18n.t("activerecord.attributes.earning.platforms.#{platform}"),
        amount: amount,
        percent: (amount.to_f / total * 100).round(1),
        color: meta[:color] || DEFAULT_COLOR
      }
    end
  end
end
