module History
  class RecordSearch
    def initialize(term)
      @term = term
    end

    def earnings(scope)
      return scope if @term.blank?

      matched_platforms = enum_matches(Earning.platforms, platform_labels)
      if matched_platforms.any?
        scope.where('notes ILIKE ? OR platform IN (?)', wildcard, matched_platforms)
      else
        scope.where('notes ILIKE ?', wildcard)
      end
    end

    def expenses(scope)
      return scope if @term.blank?

      matched_categories = enum_matches(Expense.categories, category_labels)
      if matched_categories.any?
        scope.where('description ILIKE ? OR vendor ILIKE ? OR category IN (?)', wildcard, wildcard, matched_categories)
      else
        scope.where('description ILIKE ? OR vendor ILIKE ?', wildcard, wildcard)
      end
    end

    private

    def wildcard = "%#{@term}%"

    def enum_matches(enum_map, labels)
      labels.filter_map do |key, label|
        enum_map[key.to_s] if label.downcase.include?(@term.downcase)
      end
    end

    def category_labels = I18n.t('activerecord.attributes.expense.categories')
    def platform_labels = I18n.t('activerecord.attributes.earning.platforms')
  end
end
