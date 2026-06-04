class Account::ShowView < ApplicationView
  GROUPS = [
    {
      title_key: 'account.groups.account',
      items: [
        { icon: PhlexIcons::Lucide::User,       key: 'personal_data', path_name: :coming_soon, badge: false },
        { icon: PhlexIcons::Lucide::Wallet,     key: 'plan',          path_name: :coming_soon, badge: true  },
        { icon: PhlexIcons::Lucide::Bell,       key: 'notifications', path_name: :coming_soon, badge: false }
      ]
    },
    {
      title_key: 'account.groups.preferences',
      items: [
        { icon: PhlexIcons::Lucide::Truck,      key: 'vehicle',       path_name: :vehicle,     badge: false },
        { icon: PhlexIcons::Lucide::Download,   key: 'export',        path_name: :coming_soon, badge: false },
        { icon: PhlexIcons::Lucide::LifeBuoy,   key: 'help',          path_name: :coming_soon, badge: false }
      ]
    }
  ].freeze

  APP_VERSION = '1.0.0'.freeze

  def initialize(user:)
    @user = user
  end

  def view_template
    render LayoutComponent.new(title: t('.title'), bottom_nav: :more, sidebar_nav: :more) do
      div(data: { controller: 'logout-confirm' }) do
        mobile_layout
        desktop_layout
        logout_overlay
      end
    end
  end

  private

  def mobile_layout
    div(class: 'lg:hidden') do
      header(class: 'px-5 pt-2 pb-3') do
        h1(class: 'text-2xl font-bold text-slate-800') { t('.heading') }
      end
      div(class: 'px-5 pb-10 space-y-5') do
        profile_card_mobile
        GROUPS.each { |group| group_block_mobile(group) }
        sign_out_button_mobile
        p(class: 'text-center text-[11px] text-slate-400') { t('.version_label', version: APP_VERSION) }
      end
    end
  end

  def desktop_layout
    div(class: 'hidden lg:block') do
      div(class: 'mb-6') do
        h1(class: 'text-2xl font-bold text-slate-800') { t('.heading') }
        p(class: 'text-sm text-slate-500 mt-1') { t('.desktop_subtitle') }
      end
      div(class: 'max-w-3xl space-y-6') do
        profile_card_desktop
        div(class: 'grid grid-cols-2 gap-6') do
          GROUPS.each { |group| group_block_desktop(group) }
        end
        session_block_desktop
      end
    end
  end

  def profile_card_mobile
    div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm p-4 flex items-center gap-4') do
      avatar_circle('w-14 h-14 text-xl')
      div(class: 'min-w-0 flex-1') do
        p(class: 'text-base font-bold text-slate-900') { @user.name }
        p(class: 'text-sm text-slate-500 truncate') { @user.email_address }
      end
      span(class: 'text-slate-400') { render PhlexIcons::Lucide::ChevronRight.new(class: 'w-[18px] h-[18px]') }
    end
  end

  def profile_card_desktop
    div(class: 'bg-white rounded-2xl border border-slate-200 p-6 flex items-center gap-5') do
      avatar_circle('w-16 h-16 text-2xl')
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-xl font-bold text-slate-900') { @user.name }
        p(class: 'text-sm text-slate-500') { "#{@user.email_address} · #{t('.free_plan')}" }
      end
      button(class: 'px-4 py-2 text-sm font-semibold text-blue-600 border border-blue-200 rounded-lg hover:bg-blue-50') do
        t('.edit_profile')
      end
    end
  end

  def avatar_circle(size_classes)
    div(class: "#{size_classes} rounded-full bg-blue-600 text-white flex items-center justify-center font-bold") do
      plain @user.name.to_s.strip.first&.upcase || '?'
    end
  end

  def group_block_mobile(group)
    div do
      p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') { t(group[:title_key]) }
      div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
        group[:items].each_with_index { |item, index| group_item(item, last: index == group[:items].size - 1) }
      end
    end
  end

  def group_block_desktop(group)
    div do
      p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2.5 px-1') { t(group[:title_key]) }
      div(class: 'bg-white rounded-xl border border-slate-200 overflow-hidden') do
        group[:items].each_with_index { |item, index| group_item(item, last: index == group[:items].size - 1) }
      end
    end
  end

  def group_item(item, last:)
    link_to(
      helpers.public_send("#{item[:path_name]}_path"),
      class: "w-full flex items-center gap-3 px-4 py-3.5 hover:bg-slate-50 #{'border-b border-slate-100' unless last}"
    ) do
      div(class: 'w-9 h-9 rounded-lg bg-slate-100 text-slate-600 flex items-center justify-center flex-shrink-0') do
        render item[:icon].new(class: 'w-[17px] h-[17px]')
      end
      div(class: 'flex-1 min-w-0') do
        p(class: 'text-sm font-medium text-slate-800') { t("account.items.#{item[:key]}.label") }
        p(class: 'text-xs text-slate-500 truncate') { t("account.items.#{item[:key]}.sub") }
      end
      if item[:badge]
        span(class: 'text-[10px] font-bold uppercase tracking-wide text-blue-700 bg-blue-50 border border-blue-200 rounded-full px-2 py-0.5') do
          t("account.items.#{item[:key]}.badge")
        end
      end
      render PhlexIcons::Lucide::ChevronRight.new(class: 'w-4 h-4 text-slate-300')
    end
  end

  def sign_out_button_mobile
    button(
      type: 'button',
      class: 'w-full flex items-center justify-center gap-2 bg-white border border-red-200 text-red-600 rounded-2xl py-3.5 text-sm font-semibold shadow-sm',
      data: { action: 'click->logout-confirm#open' }
    ) do
      render PhlexIcons::Lucide::LogOut.new(class: 'w-[18px] h-[18px]')
      plain t('.sign_out_button')
    end
  end

  def session_block_desktop
    div(class: 'bg-white rounded-xl border border-slate-200 p-5 flex items-center justify-between') do
      div do
        p(class: 'text-sm font-semibold text-slate-800') { t('.session_label') }
        p(class: 'text-xs text-slate-500 mt-0.5') { t('.session_description') }
      end
      button(
        type: 'button',
        class: 'flex items-center gap-2 bg-white border border-red-200 text-red-600 rounded-lg px-4 py-2 text-sm font-semibold hover:bg-red-50',
        data: { action: 'click->logout-confirm#open' }
      ) do
        render PhlexIcons::Lucide::LogOut.new(class: 'w-4 h-4')
        plain t('.sign_out_short')
      end
    end
  end

  def logout_overlay
    div(
      class: 'fixed inset-0 z-40 hidden',
      data: { 'logout-confirm-target': 'overlay' }
    ) do
      div(class: 'absolute inset-0 bg-slate-900/40', data: { action: 'click->logout-confirm#dismiss' })
      logout_sheet_mobile
      logout_modal_desktop
    end
  end

  def logout_sheet_mobile
    div(class: 'absolute left-0 right-0 bottom-0 bg-white rounded-t-3xl px-6 pt-3 pb-9 shadow-2xl lg:hidden') do
      div(class: 'w-10 h-1 rounded-full bg-slate-200 mx-auto mb-5')
      div(class: 'w-14 h-14 rounded-full bg-red-50 text-red-600 flex items-center justify-center mx-auto') do
        render PhlexIcons::Lucide::LogOut.new(class: 'w-6 h-6')
      end
      h2(class: 'text-xl font-bold text-slate-900 text-center mt-4') { t('.logout_modal.headline') }
      p(class: 'text-sm text-slate-500 text-center mt-2 leading-relaxed') { t('.logout_modal.description') }
      logout_buttons('w-full bg-red-600 hover:bg-red-700 text-white rounded-xl py-3.5 text-sm font-semibold', 'w-full bg-slate-100 text-slate-700 rounded-xl py-3.5 text-sm font-semibold mt-2.5')
    end
  end

  def logout_modal_desktop
    div(class: 'absolute inset-0 hidden lg:flex items-center justify-center p-8') do
      div(class: 'bg-white rounded-2xl shadow-2xl border border-slate-200 w-full max-w-md p-6') do
        div(class: 'w-14 h-14 rounded-full bg-red-50 text-red-600 flex items-center justify-center') do
          render PhlexIcons::Lucide::LogOut.new(class: 'w-6 h-6')
        end
        h2(class: 'text-xl font-bold text-slate-900 mt-4') { t('.logout_modal.headline') }
        p(class: 'text-sm text-slate-500 mt-2 leading-relaxed') { t('.logout_modal.description') }
        div(class: 'flex items-center justify-end gap-3 mt-6') do
          button(
            type: 'button',
            class: 'px-4 py-2 text-sm font-semibold text-slate-600 hover:text-slate-900',
            data: { action: 'click->logout-confirm#dismiss' }
          ) { t('.logout_modal.cancel') }
          inline_logout_form('px-5 py-2 text-sm font-semibold text-white bg-red-600 hover:bg-red-700 rounded-lg flex items-center gap-2', t('.logout_modal.confirm'))
        end
      end
    end
  end

  def logout_buttons(confirm_class, cancel_class)
    div(class: 'space-y-2.5 mt-6') do
      inline_logout_form(confirm_class, t('.logout_modal.confirm'))
      button(
        type: 'button',
        class: cancel_class,
        data: { action: 'click->logout-confirm#dismiss' }
      ) { t('.logout_modal.cancel') }
    end
  end

  def inline_logout_form(button_class, label)
    raw helpers.button_to(
      label,
      helpers.session_path,
      method: :delete,
      form: { data: { turbo: false } },
      class: button_class
    ).to_s
  end
end
