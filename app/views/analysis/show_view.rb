module Analysis
  class ShowView < ApplicationView
    def initialize(insights:, filters:)
      @insights = insights
      @filters = filters
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :analysis, sidebar_nav: :analysis) do
        h1(class: 'text-2xl font-bold text-slate-900') { t('.title') }
      end
    end
  end
end
