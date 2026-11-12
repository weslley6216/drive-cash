class SidebarNavComponent < ApplicationComponent
  TABS = [
    { id: :home, icon: PhlexIcons::Lucide::House, path_method: :root_path },
    { id: :analysis, icon: PhlexIcons::Lucide::ChartColumn, path_method: :analysis_path },
    { id: :goals, icon: PhlexIcons::Lucide::Target, path_method: :goals_path },
    { id: :history, icon: PhlexIcons::Lucide::List, path_method: :history_path },
    { id: :vehicle, icon: PhlexIcons::Lucide::Truck, path_method: :vehicle_path }
  ].freeze

  ACTIVE_TAB = 'bg-blue-50 text-blue-700'.freeze
  INACTIVE_TAB = 'text-slate-600 hover:bg-slate-50'.freeze

  def initialize(active:)
    @active = active
  end

  def view_template
    nav(
      id:    'sidebar-nav',
      class: 'hidden lg:flex lg:flex-col lg:w-60 lg:fixed lg:inset-y-0 bg-white border-r border-slate-200 z-30',
      data:  { turbo_permanent: '', controller: 'nav-active' }
    ) do
      brand_section
      nav_tabs
      account_section
    end
  end

  private

  def brand_section
    div(class: 'px-5 py-5 border-b border-slate-100') do
      div(class: 'flex items-center gap-2') do
        render BrandMarkComponent.new(size: :sm, wordmark: false)
        div do
          p(class: 'text-base font-bold text-slate-900 leading-tight') { I18n.t('sidebar_nav_component.brand') }
          p(class: 'text-[11px] text-slate-500') { I18n.t('sidebar_nav_component.brand_subtitle') }
        end
      end
    end
  end

  def nav_tabs
    div(class: 'flex-1 p-3 space-y-1') do
      TABS.each { |tab| tab_link(tab) }
    end
  end

  def tab_link(tab)
    active = tab[:id] == @active
    link_to(
      helpers.public_send(tab[:path_method]),
      class: "sidebar-tab w-full flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors #{active ? ACTIVE_TAB : INACTIVE_TAB}",
      data:  { nav_active_target: 'tab', active_classes: ACTIVE_TAB, inactive_classes: INACTIVE_TAB }
    ) do
      render tab[:icon].new(class: 'w-[18px] h-[18px]')
      span { I18n.t("sidebar_nav_component.tabs.#{tab[:id]}") }
    end
  end

  def account_section
    active = @active == :more
    div(class: 'p-3 border-t border-slate-100') do
      link_to(
        helpers.account_path,
        class: "w-full flex items-center gap-3 px-3 py-2 rounded-lg #{active ? 'bg-blue-50' : 'hover:bg-slate-50'}"
      ) do
        div(class: 'w-8 h-8 rounded-full bg-blue-600 text-white flex items-center justify-center text-xs font-semibold') do
          plain first_name.first&.upcase
        end
        div(class: 'flex-1 text-left') do
          p(class: "text-sm font-medium leading-tight #{active ? 'text-blue-700' : 'text-slate-800'}") { first_name }
          p(class: "text-[11px] #{active ? 'text-blue-600/80' : 'text-slate-500'}") do
            I18n.t('sidebar_nav_component.account_hint')
          end
        end
        render PhlexIcons::Lucide::ChevronRight.new(class: "w-3.5 h-3.5 #{active ? 'text-blue-400' : 'text-slate-400'}")
      end
    end
  end

  def first_name
    Current.user&.first_name.to_s
  end
end
