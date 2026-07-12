class Account::ShowView < ApplicationView
  GROUPS = [
    {
      title_key: 'account.groups.account',
      items:     [
        { icon: PhlexIcons::Lucide::User, key: 'personal_data', path_name: :edit_profile, badge: false },
        { icon: PhlexIcons::Lucide::Wallet, key: 'plan', path_name: :coming_soon, badge: true },
        { icon: PhlexIcons::Lucide::Bell, key: 'notifications', path_name: :coming_soon, badge: false }
      ]
    },
    {
      title_key: 'account.groups.preferences',
      items:     [
        { icon: PhlexIcons::Lucide::Truck, key: 'vehicle', path_name: :vehicle, badge: false },
        { icon: PhlexIcons::Lucide::Download, key: 'exports', path_name: :exports, badge: false },
        { icon: PhlexIcons::Lucide::LifeBuoy, key: 'help', path_name: :help, badge: false }
      ]
    }
  ].freeze

  APP_VERSION = '1.0.0'.freeze

  def initialize(user:, vehicle:)
    @user = user
    @vehicle = vehicle
  end

  def view_template
    render LayoutComponent.new(title: t('.title'), bottom_nav: :more, sidebar_nav: :more) do
      mobile_layout
      desktop_layout
    end
  end

  private

  def mobile_layout
    div(class: 'lg:hidden') do
      header(class: 'px-5 pt-2 pb-3') do
        h1(class: 'text-2xl font-bold text-slate-800') { t('.heading') }
        p(class: 'text-sm text-slate-500 mt-0.5') { t('.mobile_subtitle') }
      end
      div(class: 'px-5 pb-10 space-y-5') do
        profile_card_mobile
        GROUPS.each { |group| group_block_mobile(group) }
        sign_out_block_mobile
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
    link_to(helpers.edit_profile_path, class: 'bg-white rounded-2xl border border-slate-100 shadow-sm p-4 flex items-center gap-4 active:bg-slate-50') do
      render AvatarComponent.new(name: @user.name, size_classes: 'w-14 h-14 text-xl')
      div(class: 'min-w-0 flex-1') do
        div(class: 'flex items-center gap-2') do
          p(class: 'text-base font-bold text-slate-900 truncate') { @user.name }
          span(class: 'text-[10px] font-bold uppercase tracking-wide text-slate-600 bg-slate-100 border border-slate-200 rounded-full px-2 py-0.5 flex-shrink-0') { t('.plan_badge') }
        end
        p(class: 'text-sm text-slate-500 truncate') { @user.email_address }
        p(class: 'text-[11px] text-blue-600 font-medium mt-0.5') { t('.edit_profile_hint') }
      end
      render PhlexIcons::Lucide::ChevronRight.new(class: 'w-[18px] h-[18px] text-slate-300 flex-shrink-0')
    end
  end

  def profile_card_desktop
    div(class: 'bg-white rounded-2xl border border-slate-200 p-6 flex items-center gap-5') do
      render AvatarComponent.new(name: @user.name, size_classes: 'w-16 h-16 text-2xl')
      div(class: 'flex-1 min-w-0') do
        div(class: 'flex items-center gap-2') do
          p(class: 'text-xl font-bold text-slate-900') { @user.name }
          span(class: 'text-[10px] font-bold uppercase tracking-wide text-slate-600 bg-slate-100 border border-slate-200 rounded-full px-2 py-0.5') { t('.plan_badge') }
        end
        p(class: 'text-sm text-slate-500') { profile_contact_line }
      end
      div(class: 'flex items-center gap-2') do
        link_to(helpers.edit_profile_path, class: 'px-4 py-2 text-sm font-semibold text-blue-600 border border-blue-200 rounded-lg hover:bg-blue-50') { t('.edit_profile') }
        link_to(helpers.coming_soon_path, class: 'px-4 py-2 text-sm font-semibold text-white bg-blue-600 hover:bg-blue-700 rounded-lg') { t('.know_pro') }
      end
    end
  end

  def profile_contact_line
    [@user.email_address, @user.phone.presence].compact.join(' · ')
  end

  def item_sub(item)
    return vehicle_summary if item[:key] == 'vehicle'

    t("account.items.#{item[:key]}.sub")
  end

  def vehicle_summary
    return t('account.items.vehicle.sub') unless @vehicle

    "#{@vehicle.vehicle_model} #{@vehicle.year} · #{helpers.number_with_delimiter(@vehicle.odometer_km, delimiter: '.')} km"
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
        p(class: 'text-xs text-slate-500 truncate') { item_sub(item) }
      end
      if item[:badge]
        span(class: 'text-[10px] font-bold uppercase tracking-wide text-blue-700 bg-blue-50 border border-blue-200 rounded-full px-2 py-0.5') do
          t("account.items.#{item[:key]}.badge")
        end
      end
      render PhlexIcons::Lucide::ChevronRight.new(class: 'w-4 h-4 text-slate-300')
    end
  end

  def sign_out_block_mobile
    render ConfirmActionComponent.new(**logout_component_options) do
      button(
        type:  'button',
        class: 'w-full flex items-center justify-center gap-2 bg-white border border-red-200 text-red-600 rounded-2xl py-3.5 text-sm font-semibold shadow-sm cursor-pointer',
        data:  { action: 'click->confirm-action#open' }
      ) do
        render PhlexIcons::Lucide::LogOut.new(class: 'w-[18px] h-[18px]')
        plain t('.sign_out_button')
      end
    end
  end

  def session_block_desktop
    div(class: 'bg-white rounded-xl border border-slate-200 p-5 flex items-center justify-between') do
      div do
        p(class: 'text-sm font-semibold text-slate-800') { t('.session_label') }
        p(class: 'text-xs text-slate-500 mt-0.5') { t('.session_description') }
      end
      render ConfirmActionComponent.new(**logout_component_options) do
        button(
          type:  'button',
          class: 'flex items-center gap-2 bg-white border border-red-200 text-red-600 rounded-lg px-4 py-2 text-sm font-semibold hover:bg-red-50 cursor-pointer',
          data:  { action: 'click->confirm-action#open' }
        ) do
          render PhlexIcons::Lucide::LogOut.new(class: 'w-4 h-4')
          plain t('.sign_out_short')
        end
      end
    end
  end

  def logout_component_options
    {
      title:          t('.logout_modal.headline'),
      icon:           PhlexIcons::Lucide::LogOut,
      confirm_path:   helpers.session_path,
      confirm_method: :delete,
      confirm_label:  t('.logout_modal.confirm'),
      cancel_label:   t('.logout_modal.cancel'),
      description:    t('.logout_modal.description'),
      turbo:          false
    }
  end
end
