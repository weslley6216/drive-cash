module Plans
  class ShowView < ApplicationView
    def initialize(comparison:)
      @comparison = comparison
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :more, sidebar_nav: :more) do
        div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

        div(data: { controller: 'plan-billing' }) do
          mobile_layout
          desktop_layout
        end
      end
    end

    private

    def mobile_layout
      div(class: 'lg:hidden') do
        mobile_header
        div(class: 'px-5 pb-10 pt-1 space-y-5') do
          current_plan_card
          div(class: 'text-center') { render PriceToggleComponent.new(discount_percent: @comparison.yearly_discount_percent) }
          render ProCardComponent.new(comparison: @comparison)
          render FreeCardComponent.new(comparison: @comparison)
        end
      end
    end

    def mobile_header
      header(class: 'px-5 pt-2 pb-3') do
        div(class: 'flex items-center gap-3') do
          link_to(helpers.account_path, class: 'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center text-slate-600') do
            render PhlexIcons::Lucide::ArrowLeft.new(class: 'w-[18px] h-[18px]')
          end
          div do
            h1(class: 'text-xl font-bold text-slate-900') { t('.heading') }
            p(class: 'text-xs text-slate-500') { t('.mobile_subtitle') }
          end
        end
      end
    end

    def current_plan_card
      div(class: 'bg-white rounded-2xl border border-slate-100 shadow-sm p-4') do
        div(class: 'flex items-center gap-3') do
          div(class: 'w-10 h-10 rounded-xl bg-slate-100 text-slate-600 flex items-center justify-center flex-shrink-0') do
            render PhlexIcons::Lucide::Wallet.new(class: 'w-[18px] h-[18px]')
          end
          div(class: 'flex-1 min-w-0') do
            p(class: 'text-sm font-bold text-slate-800') { t('.current_plan') }
            p(class: 'text-xs text-slate-500') { t('.current_hint') }
          end
        end
      end
    end

    def desktop_layout
      div(class: 'hidden lg:block') do
        desktop_header
        div(class: 'max-w-3xl mx-auto') do
          desktop_pitch
          div(class: 'grid grid-cols-2 gap-6 items-start') do
            render FreeCardComponent.new(comparison: @comparison)
            render ProCardComponent.new(comparison: @comparison)
          end
        end
      end
    end

    def desktop_header
      div(class: 'mb-6 flex items-center justify-between') do
        div do
          h1(class: 'text-2xl font-bold text-slate-800') { t('.heading') }
          p(class: 'text-sm text-slate-500 mt-1') { t('.desktop_subtitle') }
        end
        render PriceToggleComponent.new(discount_percent: @comparison.yearly_discount_percent)
      end
    end

    def desktop_pitch
      div(class: 'text-center mb-8 mt-2') do
        h2(class: 'text-3xl font-bold text-slate-900 tracking-tight') { t('.desktop_headline') }
        p(class: 'text-sm text-slate-500 mt-2') { t('.desktop_subheadline') }
      end
    end
  end
end
