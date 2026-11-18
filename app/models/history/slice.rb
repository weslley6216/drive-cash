module History
  class Slice
    TYPES = %w[earnings expenses].freeze
    RANGES = %w[12m].freeze
    NO_VENDOR = '__none__'.freeze
    PRESETS = {
      'all'      => {},
      'earnings' => { types: %w[earnings] },
      'expenses' => { types: %w[expenses] },
      'unpaid'   => { types: %w[expenses], unpaid: '1' }
    }.freeze

    attr_reader :types, :categories, :platforms, :vendors, :range

    def self.from_params(params)
      params = params.with_indifferent_access
      new(types: params[:types], unpaid: params[:unpaid], categories: params[:categories],
          platforms: params[:platforms], vendors: params[:vendors], range: params[:range])
    end

    def self.preset(key)
      new(**PRESETS.fetch(key, {}))
    end

    def initialize(types: [], unpaid: nil, categories: [], platforms: [], vendors: {}, range: nil)
      @categories = sanitize_list(categories, Expense.categories.keys)
      @platforms = sanitize_list(platforms, Earning.platforms.keys)
      @unpaid = %w[1 true].include?(unpaid.to_s)
      @types = sanitize_types(types)
      @vendors = sanitize_vendors(vendors)
      @range = sanitize_range(range)
    end

    def unpaid?
      @unpaid
    end

    def include_earnings?
      @types.empty? || @types.include?('earnings')
    end

    def include_expenses?
      @types.empty? || @types.include?('expenses')
    end

    def filtering?
      @categories.any? || @platforms.any? || @vendors.any?
    end

    def pill_count
      @categories.size + @platforms.size + @vendors.values.sum(&:size)
    end

    def single_series?
      (@categories.one? && @platforms.empty? && !include_earnings?) ||
        (@platforms.one? && @categories.empty? && !include_expenses?)
    end

    def twelve_months?
      @range == '12m'
    end

    def active_preset
      return nil if filtering?

      PRESETS.keys.find { |key| preset_matches?(key) }
    end

    def to_params
      params = {}
      params[:types] = @types if @types.any?
      params[:unpaid] = '1' if @unpaid
      params[:categories] = @categories if @categories.any?
      params[:platforms] = @platforms if @platforms.any?
      params[:vendors] = @vendors if @vendors.any?
      params[:range] = @range if @range
      params
    end

    def without_category(category)
      self.class.from_params(to_params.merge(categories: @categories - [category], vendors: @vendors.except(category)))
    end

    def without_vendors(category)
      self.class.from_params(to_params.merge(vendors: @vendors.except(category)))
    end

    def without_platform(platform)
      self.class.from_params(to_params.merge(platforms: @platforms - [platform]))
    end

    def without_unpaid
      self.class.from_params(to_params.except(:unpaid))
    end

    def with_twelve_months
      self.class.from_params(to_params.merge(range: '12m'))
    end

    def without_range
      self.class.from_params(to_params.except(:range))
    end

    private

    def sanitize_list(list, known_values)
      Array(list).map(&:to_s) & known_values
    end

    def sanitize_types(types)
      explicit = sanitize_list(types, TYPES)
      implied = []
      implied << 'expenses' if @categories.any? || @unpaid
      implied << 'earnings' if @platforms.any?

      TYPES & (explicit + implied)
    end

    def sanitize_vendors(vendors)
      vendors.to_h.slice(*@categories).filter_map do |category, names|
        sanitized = Array(names).map { |name| name.to_s.strip }.reject(&:blank?).uniq
        [category.to_s, sanitized] if sanitized.any?
      end.to_h
    end

    def sanitize_range(range)
      range.to_s if RANGES.include?(range.to_s) && single_series?
    end

    def preset_matches?(key)
      preset = self.class.preset(key)

      preset.include_earnings? == include_earnings? && preset.include_expenses? == include_expenses? &&
        preset.unpaid? == @unpaid
    end
  end
end
