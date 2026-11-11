module Maintenances
  class MarkDoneFormView < ApplicationView
    def initialize(request:)
      @request = request
    end

    def view_template
      turbo_frame_tag 'modal' do
        div do
          h2 { title }
          error_message
          render_form
        end
      end
    end

    private

    def maintenance = @request.maintenance

    def title
      t('maintenances.mark_done.title', item: t("vehicle.maintenances.catalog.#{maintenance.category}"))
    end

    def error_message
      return if @request.errors[:done_km].blank?

      p { @request.errors[:done_km].first }
    end

    def render_form
      form_with(model: @request, scope: :mark_done, url: helpers.maintenance_mark_done_path(maintenance), method: :patch) do |form|
        render form.hidden_field(:done_km)
        render form.hidden_field(:done_on)
        button(type: 'submit') { t('maintenances.mark_done.buttons.save') }
      end
    end
  end
end
