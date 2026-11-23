module Ai
  module FuelVendorName
    PREFIX = 'Posto'.freeze
    PREFIXED = /\Aposto(?=\s|\z)/i

    def self.call(params)
      vendor = params['vendor']
      return params unless params['category'] == 'fuel' && vendor.present?

      params.merge('vendor' => prefixed(vendor.strip))
    end

    def self.prefixed(vendor)
      vendor.match?(PREFIXED) ? vendor.sub(PREFIXED, PREFIX) : "#{PREFIX} #{vendor}"
    end
    private_class_method :prefixed
  end
end
