module History
  class SliceQuery
    def initialize(slice)
      @slice = slice
    end

    def earnings(scope)
      return scope.none unless @slice.include_earnings?

      @slice.platforms.any? ? scope.where(platform: @slice.platforms) : scope
    end

    def expenses(scope)
      return scope.none unless @slice.include_expenses?

      scope = scope.where(paid: false) if @slice.unpaid?
      scope = scope_by_categories(scope) if @slice.categories.any?
      scope
    end

    private

    def scope_by_categories(scope)
      @slice.categories.reduce(scope.none) do |accumulated, category|
        accumulated.or(scope_by_category(scope, category))
      end
    end

    def scope_by_category(scope, category)
      vendors = @slice.vendors[category]
      base = scope.where(category: category)
      return base if vendors.blank?

      base.and(scope_by_vendors(scope, vendors))
    end

    def scope_by_vendors(scope, vendors)
      named = vendors - [Slice::NO_VENDOR]
      conditions = []
      conditions << scope.where(vendor: named) if named.any?
      conditions << scope.where(vendor: [nil, '']) if vendors.include?(Slice::NO_VENDOR)

      conditions.reduce(scope.none) { |accumulated, condition| accumulated.or(condition) }
    end
  end
end
