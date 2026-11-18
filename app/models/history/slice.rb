module History
  class Slice
    TYPES = %w[earnings expenses].freeze
    NO_VENDOR = '__none__'.freeze
    PRESETS = {
      'all'      => {},
      'earnings' => { types: %w[earnings] },
      'expenses' => { types: %w[expenses] },
      'unpaid'   => { types: %w[expenses], unpaid: '1' }
    }.freeze

    attr_reader :types, :categories, :platforms, :vendors

    def self.from_params(params)
      params = params.with_indifferent_access
      new(types: params[:types], unpaid: params[:unpaid], categories: params[:categories],
          platforms: params[:platforms], vendors: params[:vendors])
    end

    def self.preset(key)
      new(**PRESETS.fetch(key, {}))
    end

    def initialize(types: [], unpaid: nil, categories: [], platforms: [], vendors: {})
      @categories = sanitize_list(categories, Expense.categories.keys)
      @platforms = sanitize_list(platforms, Earning.platforms.keys)
      @unpaid = %w[1 true].include?(unpaid.to_s)
      @types = sanitize_types(types)
      @vendors = sanitize_vendors(vendors)
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

    def preset_matches?(key)
      preset = self.class.preset(key)

      preset.include_earnings? == include_earnings? && preset.include_expenses? == include_expenses? &&
        preset.unpaid? == @unpaid
    end
  end
end
