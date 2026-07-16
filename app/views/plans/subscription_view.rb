module Plans
  class SubscriptionView < ApplicationView
    def initialize(subscription:)
      @subscription = subscription
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :more, sidebar_nav: :more) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        page_header
        div(class: 'px-5 lg:px-0 pb-10 lg:max-w-2xl space-y-5') do
          subscription_card
          benefits_section
          management_section
          p(class: 'text-center text-[11px] text-slate-400') { t('.cancel_note') }
        end
      end
    end

    private

    def page_header
      header(class: 'px-5 lg:px-1 pt-2 pb-3') do
        div(class: 'flex items-center gap-3') do
          link_to(helpers.account_path, class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center text-slate-600 lg:hidden') do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[18px] h-[18px]')
          end
          div do
            h1(class: 'text-xl lg:text-2xl font-bold text-slate-900') { t('.heading') }
            p(class: 'text-xs lg:text-sm text-slate-500') { t('.subtitle') }
          end
        end
      end
    end

    def subscription_card
      div(class: 'rounded-2xl bg-blue-600 p-5 text-white shadow-lg shadow-blue-600/20') do
        div(class: 'flex items-center justify-between') do
          div(class: 'flex items-center gap-2') do
            render PhlexIcons::Lucide::Zap.new(class: 'w-[18px] h-[18px]')
            p(class: 'text-base font-bold') { t('.brand') }
          end
          span(class: 'text-[10px] font-bold uppercase tracking-wide bg-white/15 border border-white/25 rounded-full px-2 py-0.5') do
            t('.active_badge')
          end
        end
        p(class: 'text-sm text-blue-100 mt-2') { billing_line }
        p(class: 'text-xs text-blue-200 mt-1') { next_charge_line }
      end
    end

    def billing_line
      t(".billing_line.#{@subscription.billing}", price: format_currency(@subscription.price))
    end

    def next_charge_line
      t('.next_charge', date: l(@subscription.next_charge_on, format: :long))
    end

    def benefits_section
      div do
        p(class: 'text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2 px-1') { t('.benefits_title') }
        div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm p-5') do
          render BenefitListComponent.new(features: @subscription.features)
        end
      end
    end

    def management_section
      div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden') do
        management_link(PhlexIcons::Lucide::Receipt, t('.payment_history'))
        management_link(PhlexIcons::Lucide::Settings, t('.manage'), last: true)
      end
    end

    def management_link(icon, label, last: false)
      link_to(helpers.coming_soon_path, class: "w-full flex items-center gap-3 px-4 py-3.5 hover:bg-slate-50 #{'border-b border-slate-100' unless last}") do
        div(class: 'w-9 h-9 rounded-lg bg-slate-100 text-slate-600 flex items-center justify-center') do
          render icon.new(class: 'w-[17px] h-[17px]')
        end
        span(class: 'text-sm font-medium text-slate-800 flex-1') { label }
        render PhlexIcons::Lucide::ChevronRight.new(class: 'w-4 h-4 text-slate-300')
      end
    end
  end
end
