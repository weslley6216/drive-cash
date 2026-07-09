module Chat
  module Summaries
    class Maintenance < Base
      def call
        category = I18n.t("vehicle.maintenances.catalog.#{@params['category']}", default: '')
        km = @params['done_km'] ? " aos #{@params['done_km']} km" : ''
        I18n.t('chat.preview.maintenance', category: category, km: km)
      end
    end
  end
end
