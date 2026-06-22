module VendorNormalization
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_vendor
  end

  private

  def normalize_vendor
    return unless vendor.is_a?(String)
    return unless vendor_changed?

    self.vendor = vendor.strip.gsub(/\s+/, ' ')
  end
end
