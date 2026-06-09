class BottomNavComponent < ApplicationComponent
  TABS = [
    { id: :home,     label_key: 'bottom_nav_component.tabs.home',     icon: PhlexIcons::Lucide::House,             path_method: :root_path },
    { id: :analysis, label_key: 'bottom_nav_component.tabs.analysis', icon: PhlexIcons::Lucide::ChartColumn,       path_method: :analysis_path },
    { id: :journey,  label_key: 'bottom_nav_component.tabs.journey',  icon: PhlexIcons::Lucide::Play,              path_method: :work_session_path },
    { id: :history,  label_key: 'bottom_nav_component.tabs.history',  icon: PhlexIcons::Lucide::List,              path_method: :history_path },
    { id: :more,     label_key: 'bottom_nav_component.tabs.more',     icon: PhlexIcons::Lucide::SlidersHorizontal, path_method: :account_path }
  ].freeze

  def initialize(active:)
    @active = active
  end

  def view_template
    nav(class: 'fixed bottom-0 left-0 right-0 bg-white border-t border-slate-200 px-2 pt-2 pb-6 z-30 lg:hidden') do
      div(class: 'flex items-stretch justify-around max-w-md mx-auto') do
        TABS.each { |tab| tab_button(tab) }
      end
    end
  end

  private

  def tab_button(tab)
    active = tab[:id] == @active
    link_to(
      safe_path(tab[:path_method]),
      class: "flex flex-col items-center gap-1 px-2 py-1 rounded-lg #{active ? 'text-blue-600' : 'text-slate-400'}"
    ) do
      render tab[:icon].new(class: "w-[22px] h-[22px] #{active ? 'stroke-[2.4]' : 'stroke-2'}")
      span(class: 'text-[10px] font-medium') { I18n.t(tab[:label_key]) }
    end
  end

  def safe_path(method)
    helpers.respond_to?(method) ? helpers.public_send(method) : '#'
  end
end
