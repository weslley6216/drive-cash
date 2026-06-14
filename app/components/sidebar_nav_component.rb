class SidebarNavComponent < ApplicationComponent
  TABS = [
    { id: :home, icon: PhlexIcons::Lucide::House, path_method: :root_path },
    { id: :analysis, icon: PhlexIcons::Lucide::ChartColumn, path_method: :analysis_path },
    { id: :goals, icon: PhlexIcons::Lucide::Target, path_method: :goals_path },
    { id: :journey, icon: PhlexIcons::Lucide::Play, path_method: :work_session_path },
    { id: :history, icon: PhlexIcons::Lucide::List, path_method: :history_path },
    { id: :vehicle, icon: PhlexIcons::Lucide::Truck, path_method: :vehicle_path }
  ].freeze

  def initialize(active:)
    @active = active
  end

  def view_template
    nav(
      id:    'sidebar-nav',
      class: 'hidden lg:flex lg:flex-col lg:w-64 lg:fixed lg:inset-y-0 bg-white border-r border-slate-200 z-30',
      data:  { turbo_permanent: '', controller: 'nav-active' }
    ) do
      brand_section
      nav_tabs
      settings_section
    end
  end

  private

  def brand_section
    div(class: 'p-5 border-b border-slate-100') do
      div(class: 'flex items-center gap-3') do
        render BrandMarkComponent.new(size: :sm, wordmark: false)
        div do
          p(class: 'font-bold text-slate-800 text-sm') { I18n.t('sidebar_nav_component.brand') }
          p(class: 'text-xs text-slate-500') { I18n.t('sidebar_nav_component.brand_subtitle') }
        end
      end
    end
  end

  def nav_tabs
    div(class: 'flex-1 py-4 px-3 space-y-1') do
      TABS.each { |tab| tab_link(tab) }
    end
  end

  def tab_link(tab)
    active = tab[:id] == @active
    link_to(
      helpers.public_send(tab[:path_method]),
      class: "sidebar-tab flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors #{active ? 'bg-blue-50 text-blue-700' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}",
      data:  {
        nav_active_target: 'tab',
        active_classes:    'bg-blue-50 text-blue-700',
        inactive_classes:  'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
      }
    ) do
      render tab[:icon].new(
        class: "w-5 h-5 #{active ? 'text-blue-600' : 'text-slate-400'}",
        data:  {
          nav_active_target: 'icon',
          active_classes:    'text-blue-600',
          inactive_classes:  'text-slate-400'
        }
      )
      span { I18n.t("sidebar_nav_component.tabs.#{tab[:id]}") }
    end
  end

  def settings_section
    div(class: 'p-4 border-t border-slate-100 space-y-2') do
      link_to(
        helpers.settings_path,
        class: 'flex items-center gap-3 px-3 py-2 rounded-lg text-sm text-slate-600 hover:bg-slate-50 hover:text-slate-900'
      ) do
        div(class: 'w-8 h-8 rounded-full bg-slate-700 flex items-center justify-center') do
          span(class: 'text-white text-xs font-medium') { 'W' }
        end
        span { I18n.t('sidebar_nav_component.settings') }
      end

      raw helpers.button_to(
        I18n.t('sessions.sign_out'),
        helpers.session_path,
        method: :delete,
        form:   { data: { turbo_confirm: I18n.t('sessions.sign_out') } },
        class:  'w-full text-left px-3 py-2 rounded-lg text-sm text-slate-500 hover:bg-slate-50 hover:text-slate-900'
      )
    end
  end
end
