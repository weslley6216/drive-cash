module Plans
  class BenefitListComponent < ApplicationComponent
    def initialize(features:, muted: false)
      @features = features
      @muted = muted
    end

    def view_template
      ul(class: 'space-y-2.5') do
        @features.each { |feature| benefit_item(feature) }
      end
    end

    private

    def benefit_item(feature)
      li(class: 'flex items-start gap-2.5') do
        render PhlexIcons::Lucide::Check.new(class: "w-[15px] h-[15px] mt-0.5 flex-shrink-0 #{icon_classes}")
        span(class: "text-sm leading-snug #{text_classes}") { t("plans.features.#{feature}") }
      end
    end

    def icon_classes = @muted ? 'text-slate-400' : 'text-emerald-500'

    def text_classes = @muted ? 'text-slate-500' : 'text-slate-700'
  end
end
