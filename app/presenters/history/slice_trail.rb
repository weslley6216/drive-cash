module History
  class SliceTrail
    Pill = Data.define(:label, :level, :nested, :remove_params)

    def initialize(slice)
      @slice = slice
    end

    def pills
      return [] unless @slice.filtering?

      [unpaid_pill, *platform_pills, *category_pills].compact
    end

    def sentence
      [*platform_sentences, *category_sentences].to_sentence
    end

    private

    def unpaid_pill
      return nil unless @slice.unpaid?

      Pill.new(label: I18n.t('history.index.filters.unpaid'), level: 'types', nested: false,
               remove_params: @slice.without_unpaid.to_params)
    end

    def platform_pills
      @slice.platforms.map do |platform|
        Pill.new(label: platform_label(platform), level: 'platforms', nested: false,
                 remove_params: @slice.without_platform(platform).to_params)
      end
    end

    def category_pills
      @slice.categories.flat_map do |category|
        [category_pill(category), vendor_pill(category)].compact
      end
    end

    def category_pill(category)
      Pill.new(label: category_label(category), level: 'categories', nested: false,
               remove_params: @slice.without_category(category).to_params)
    end

    def vendor_pill(category)
      vendors = @slice.vendors[category]
      return nil if vendors.blank?

      Pill.new(label: vendor_label(category, vendors), level: 'vendors', nested: true,
               remove_params: @slice.without_vendors(category).to_params)
    end

    def vendor_label(category, vendors)
      return vendor_name(vendors.first) if vendors.one?

      category == 'fuel' ? I18n.t('history.index.trail.fuel_vendors', count: vendors.size) : I18n.t('history.index.trail.vendors', count: vendors.size)
    end

    def vendor_name(vendor)
      vendor == Slice::NO_VENDOR ? I18n.t('history.index.panel.no_vendor') : vendor
    end

    def platform_sentences
      @slice.platforms.map { |platform| platform_label(platform) }
    end

    def category_sentences
      @slice.categories.map do |category|
        vendors = @slice.vendors[category]
        next category_label(category) if vendors.blank?

        I18n.t('history.index.trail.sentence_vendor', category: category_label(category), vendors: vendor_label(category, vendors))
      end
    end

    def category_label(category) = I18n.t("activerecord.attributes.expense.categories.#{category}")
    def platform_label(platform) = I18n.t("activerecord.attributes.earning.platforms.#{platform}")
  end
end
