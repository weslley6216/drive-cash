module Dashboard
  class IndexView < ApplicationComponent
    def initialize(totals:, first_name:, filters: {}, recent_activity: [], categories: [], today: nil, monthly_goal: nil)
      @totals = totals
      @first_name = first_name
      @filters = filters
      @recent_activity = recent_activity
      @categories = categories
      @today = today
      @monthly_goal = monthly_goal
    end

    def view_template
      render LayoutComponent.new(title: t('.title'), bottom_nav: :home, sidebar_nav: :home) do
        turbo_frame_tag 'page' do
          div(id: 'flash') { render FlashComponent.new(flash: helpers.flash) }

          topbar_section
          loading_region

          render FabComponent.new(filters: { year: @filters[:year], month: @filters[:month] }, bottom_nav: true)
        end
        turbo_frame_tag 'modal'
      end
    end

    private

    def topbar_section
      div(class: 'mb-6 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between') do
        div(class: 'flex items-center justify-between') do
          div do
            h1(class: 'text-2xl lg:text-3xl font-bold text-slate-900 tracking-tight') { t('.greeting', name: @first_name) }
            p(class: 'text-sm text-slate-500 mt-0.5') { t('.subtitle_period', year: @filters[:year]) }
          end
          div(class: 'flex items-center gap-2 lg:hidden') do
            bell_button
            avatar_link
          end
        end

        div(class: 'flex items-center gap-2 flex-wrap') do
          render FilterComponent.new(
            selected_year:   @filters[:year],
            selected_month:  @filters[:month],
            available_years: @filters[:available_years],
            variant:         :compact
          )
          link_to(new_earning_path,
                  data:  { turbo_frame: 'modal' },
                  class: new_record_button_classes) do
            render PhlexIcons::Lucide::Plus.new(class: 'w-4 h-4')
            plain t('.new_record')
          end
          div(class: 'hidden lg:flex items-center gap-2') do
            bell_button
            avatar_link
          end
        end
      end
    end

    def new_record_button_classes
      'hidden lg:inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 ' \
      'text-white rounded-lg px-4 py-2 text-sm font-semibold'
    end

    def bell_button
      button(
        type:     'button',
        disabled: true,
        class:    'w-9 h-9 rounded-full bg-white border border-slate-200 shadow-sm flex items-center justify-center text-slate-600'
      ) do
        render PhlexIcons::Lucide::Bell.new(class: 'w-[18px] h-[18px]')
      end
    end

    def avatar_link
      a(href:  account_path,
        class: 'w-9 h-9 rounded-full bg-blue-600 text-white flex items-center justify-center font-semibold text-sm') do
        plain @first_name.to_s.first&.upcase || '?'
      end
    end

    def loading_region
      div(class: 'feed-loading-region') do
        div(class: 'feed-loading-overlay feed-loading-overlay--page') do
          div(class: 'w-8 h-8 rounded-full border-4 border-slate-100 border-t-blue-600 animate-spin')
        end

        primary_grid
        stats_grid_section
        monthly_goal_mobile_section
        secondary_grid
      end
    end

    def primary_grid
      div(class: 'grid grid-cols-1 lg:grid-cols-12 gap-4 mb-6') do
        div(id: 'hero_profit_card', class: 'lg:col-span-8') do
          render HeroProfitCardComponent.new(hero: hero_payload)
        end

        div(class: 'lg:col-span-4 flex flex-col gap-4') do
          render CajuQuickAccessComponent.new
          div(id: 'today_card') { render TodayCardComponent.new(**@today) if @today }
        end
      end
    end

    def hero_payload
      monthly_view = @filters[:month].present?
      HeroProfitCardComponent::Payload.new(
        profit:         @totals[:profit],
        change_percent: @totals[:change_percent],
        profit_per_day: @totals[:profit_per_day],
        days_count:     @totals[:days],
        series:         monthly_view ? @totals[:daily_profit_series] : @totals[:monthly_profit_series],
        year:           @filters[:year],
        month:          @filters[:month]
      )
    end

    def monthly_goal_mobile_section
      div(id: 'monthly_goal_card', class: 'lg:hidden mb-6') do
        render Goals::MonthlyGoalCardComponent.new(progress: @monthly_goal) if @monthly_goal
      end
    end

    def stats_grid_section
      render StatsGridComponent.new(
        totals: @totals,
        month:  @filters[:month],
        year:   @filters[:year]
      )
    end

    def secondary_grid
      div(class: 'grid grid-cols-1 lg:grid-cols-12 gap-4 mb-6') do
        div(id: 'recent_activity', class: 'lg:col-span-7') do
          render RecentActivityComponent.new(rows: @recent_activity)
        end
        div(id: 'category_breakdown', class: 'lg:col-span-5') do
          render CategoryBreakdownComponent.new(categories: @categories)
        end
      end
    end
  end
end
