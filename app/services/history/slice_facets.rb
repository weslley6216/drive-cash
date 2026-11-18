module History
  class SliceFacets
    def initialize(user:, year:, month:, query: nil)
      @user = user
      @year = year
      @month = month
      @search = RecordSearch.new(query)
    end

    def call
      {
        earnings_count: earnings_scope.count,
        expenses_count: expenses_scope.count,
        platforms:      platform_facets,
        categories:     category_facets,
        vendors:        vendor_facets,
        rows:           rows
      }
    end

    private

    attr_reader :user, :year, :month

    def earnings_scope
      @search.earnings(user.earnings.in_period(year, month))
    end

    def expenses_scope
      @search.expenses(user.expenses.in_period(year, month))
    end

    def platform_facets
      earnings_scope.group(:platform)
        .pluck(:platform, Arel.sql('COUNT(*)'), Arel.sql('SUM(amount)'))
        .to_h { |platform, count, total| [platform, { count: count, total: total.to_f }] }
    end

    def expense_breakdown
      @expense_breakdown ||= expenses_scope.group(:category, :vendor, :paid)
        .pluck(:category, :vendor, :paid, Arel.sql('COUNT(*)'), Arel.sql('SUM(amount)'))
        .map do |category, vendor, paid, count, total|
                                              { category: category, vendor: normalize_vendor(vendor), paid: paid, count: count, total: total.to_f }
                                            end
    end

    def category_facets
      expense_breakdown.group_by { |row| row[:category] }.transform_values do |rows|
        { count: rows.sum { |row| row[:count] }, total: rows.sum { |row| row[:total] } }
      end
    end

    def vendor_facets
      expense_breakdown.group_by { |row| row[:category] }.transform_values do |rows|
        merged_vendors(rows).sort_by { |vendor| [vendor[:vendor] == Slice::NO_VENDOR ? 1 : 0, -vendor[:count], vendor[:vendor]] }
      end
    end

    def merged_vendors(rows)
      rows.group_by { |row| row[:vendor] }.map do |vendor, group|
        { vendor: vendor, count: group.sum { |row| row[:count] }, total: group.sum { |row| row[:total] } }
      end
    end

    def rows
      earnings_rows + expenses_rows
    end

    def earnings_rows
      platform_facets.map { |platform, data| { type: 'earnings', platform: platform, count: data[:count] } }
    end

    def expenses_rows
      expense_breakdown.group_by { |row| row.values_at(:category, :vendor, :paid) }
        .map do |(category, vendor, paid), group|
                          { type: 'expenses', category: category, vendor: vendor, paid: paid, count: group.sum { |row| row[:count] } }
                        end
    end

    def normalize_vendor(vendor)
      vendor.presence || Slice::NO_VENDOR
    end
  end
end
