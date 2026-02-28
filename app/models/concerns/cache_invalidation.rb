module CacheInvalidation
  extend ActiveSupport::Concern

  included do
    after_commit :clear_available_years_cache
  end

  private

  def clear_available_years_cache
    Rails.cache.delete('dashboard/available_years')
  end
end
