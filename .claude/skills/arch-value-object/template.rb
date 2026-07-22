module DomainName
  class ValueObjectName
    VARIATION = {
      'variant_key' => ->(input) { input }
    }.freeze

    attr_reader :identifier

    def initialize(raw_amount:, raw_kind:)
      @amount = BigDecimal(raw_amount.to_s)
      @kind = raw_kind.to_s
      @identifier = SecureRandom.uuid
    end

    def valid?
      @amount.positive? && OwnerModel::SUPPORTED_KINDS.include?(@kind)
    end

    def derived_values
      @derived_values ||= compute_derived_values
    end

    private

    def compute_derived_values
      VARIATION.fetch(@kind).call(@amount)
    end
  end
end
