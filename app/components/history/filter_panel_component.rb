module History
  class FilterPanelComponent < ApplicationComponent
    include CategoryPalette
    include PlatformPalette

    def initialize(slice:, facets:, year:, month:, query:)
      @slice = slice
      @facets = facets
      @year = year
      @month = month
      @query = query
    end

    def view_template
      div(class: 'hidden', data: { history_filter_panel_target: 'panel' }) do
        div(class: 'fixed inset-0 z-50 flex lg:absolute lg:inset-auto lg:left-0 lg:top-full lg:mt-2') do
          backdrop
          sheet
        end
      end
    end

    private

    def backdrop
      div(
        class: 'w-[15%] bg-slate-900/40 lg:fixed lg:inset-0 lg:w-auto lg:bg-slate-900/10',
        data:  { history_filter_panel_target: 'backdrop', action: 'click->history-filter-panel#close' }
      )
    end

    def sheet
      div(
        class: 'relative z-10 flex-1 bg-slate-50 flex flex-col shadow-2xl safe-top ' \
               'lg:flex-none lg:w-[820px] lg:h-[470px] lg:bg-white lg:rounded-xl lg:border lg:border-slate-200 lg:shadow-2xl',
        data:  { history_filter_panel_target: 'sheet' }
      ) do
        mobile_header
        panel_form
      end
    end

    def mobile_header
      div(class: 'flex items-center justify-between px-4 py-3 bg-white border-b border-slate-200 lg:hidden') do
        div do
          p(class: 'text-base font-bold text-slate-900') { t('history.index.panel.title') }
          p(class: 'text-[11px] text-slate-500') { period_label }
        end
        button(
          type:  'button',
          class: 'w-11 h-11 -mr-2 flex items-center justify-center text-slate-500',
          aria:  { label: t('history.index.panel.close') },
          data:  { action: 'history-filter-panel#close' }
        ) { render PhlexIcons::Lucide::X.new(class: 'w-5 h-5') }
      end
    end

    def panel_form
      form(
        action: history_path,
        method: 'get',
        class:  'flex-1 flex flex-col min-h-0',
        data:   {
          history_filter_panel_target: 'form',
          turbo_action:                'advance',
          facets:                      @facets[:rows].to_json,
          labels:                      labels_json,
          action:                      'change->history-filter-panel#sync'
        }
      ) do
        hidden_fields
        body
        footer
      end
    end

    def hidden_fields
      input(type: 'hidden', name: 'year', value: @year) if @year.present?
      input(type: 'hidden', name: 'month', value: @month) if @month.present?
      input(type: 'hidden', name: 'q', value: @query) if @query.present?
    end

    def labels_json
      t('history.index.panel.submit').merge(
        all:                      t('history.index.panel.submit_all', count: total_count),
        none:                     t('history.index.panel.submit_none'),
        platforms:                t('history.index.panel.platforms'),
        categories:               t('history.index.panel.categories'),
        platforms_and_categories: t('history.index.panel.platforms_and_categories')
      ).to_json
    end

    def total_count
      @facets[:earnings_count] + @facets[:expenses_count]
    end

    def body
      div(class: 'flex-1 overflow-y-auto px-4 py-4 space-y-3 lg:flex-1 lg:overflow-visible lg:p-0') do
        hint_section
        div(class: 'space-y-3 lg:space-y-0 lg:flex lg:h-full') do
          type_section
          column2
          vendors_section
        end
      end
    end

    def hint_section
      div(
        class: 'rounded-xl border border-dashed border-slate-300 px-4 py-4 text-center lg:hidden',
        data:  { history_filter_panel_target: 'hint' }
      ) { p(class: 'text-xs text-slate-500 leading-relaxed') { raw safe(t('history.index.panel.hint_html')) } }
    end

    def type_section
      div(class: 'lg:flex-1 lg:min-w-0 lg:flex lg:flex-col lg:border-r lg:border-slate-100', data: { level: 'types' }) do
        p(class: 'text-[10px] font-bold uppercase tracking-wider text-slate-500 mb-1.5 px-1 lg:mb-0 lg:px-4 lg:pt-3 lg:pb-2') do
          t('history.index.panel.type')
        end
        div(class: 'rounded-xl border border-slate-200 bg-white py-1 lg:rounded-none lg:border-0 lg:py-0 lg:flex-1 lg:overflow-y-auto') do
          type_row('earnings', @facets[:earnings_count])
          type_row('expenses', @facets[:expenses_count])
          unpaid_row
        end
      end
    end

    def type_row(type, count)
      item_row(name: 'types[]', value: type, text: t("history.index.panel.#{type}"), checked: @slice.types.include?(type), count: count)
    end

    def unpaid_row
      label(
        class: 'flex items-center gap-3 pl-11 pr-3 min-h-[44px] border-t border-slate-100 cursor-pointer lg:pl-7 lg:border-t-0 lg:py-2',
        data:  { history_filter_panel_target: 'unpaidRow' }
      ) do
        input(type: 'checkbox', name: 'unpaid', value: '1', checked: @slice.unpaid?, class: 'peer sr-only')
        span(class: 'flex-1 text-sm text-slate-700') { t('history.index.panel.unpaid_only') }
        switch_visual
      end
    end

    def switch_visual
      span(class: 'w-10 h-6 rounded-full p-0.5 flex bg-slate-200 peer-checked:bg-blue-600 peer-checked:justify-end lg:w-9 lg:h-5') do
        span(class: 'w-5 h-5 rounded-full bg-white shadow-sm lg:w-4 lg:h-4')
      end
    end

    def column2
      div(class: 'space-y-3 lg:space-y-0 lg:flex-1 lg:min-w-0 lg:flex lg:flex-col lg:border-r lg:border-slate-100') do
        column2_desktop_header
        platforms_section
        categories_section
      end
    end

    def column2_desktop_header
      div(class: 'hidden lg:block px-3 pt-3 pb-2') do
        p(class: 'text-[10px] font-bold uppercase tracking-wider text-slate-500', data: { history_filter_panel_target: 'columnTitle' }) do
          column2_title
        end
      end
    end

    def column2_title
      return t('history.index.panel.platforms') if @slice.include_earnings? && !@slice.include_expenses?
      return t('history.index.panel.categories') if @slice.include_expenses? && !@slice.include_earnings?

      t('history.index.panel.platforms_and_categories')
    end

    def platforms_section
      div(class: group_card_classes, data: { level: 'platforms' }) do
        group_header(title: t('history.index.panel.platforms'), subtitle: t('history.index.panel.platforms_subtitle'), group: 'platforms')
        div(class: group_body_classes, data: { history_filter_panel_target: 'columnEmpty' }) do
          Earning.platforms.keys.each { |platform| platform_row(platform) }
        end
      end
    end

    def categories_section
      div(class: group_card_classes, data: { level: 'categories' }) do
        group_header(title: t('history.index.panel.categories'), subtitle: t('history.index.panel.categories_subtitle'), group: 'categories')
        div(class: group_body_classes, data: { history_filter_panel_target: 'columnEmpty' }) do
          Expense.categories.keys.each { |category| category_row(category) }
        end
      end
    end

    def group_header(title:, subtitle:, group:)
      button(
        type:  'button',
        class: 'flex items-center gap-2 px-3 min-h-[44px] w-full lg:hidden',
        data:  { action: 'history-filter-panel#toggleGroup' }
      ) do
        div(class: 'flex-1 min-w-0 text-left') do
          p(class: 'text-sm font-bold text-slate-800') { title }
          p(class: 'text-[11px] text-slate-500 truncate', data: { history_filter_panel_target: 'groupSub', group: group }) { subtitle }
        end
        span(
          class: 'min-w-[20px] h-5 px-1.5 rounded-full bg-blue-100 text-blue-700 text-[11px] font-bold items-center justify-center hidden',
          data:  { history_filter_panel_target: 'groupBadge', group: group }
        )
        render PhlexIcons::Lucide::ChevronUp.new(class: 'w-4 h-4 text-slate-400')
      end
    end

    def group_card_classes
      'rounded-xl border border-slate-200 bg-white overflow-hidden lg:rounded-none lg:border-0 lg:overflow-visible lg:flex-1 lg:flex lg:flex-col lg:min-h-0'
    end

    def group_body_classes
      'border-t border-slate-100 py-1 lg:border-t-0 lg:py-0 lg:flex-1 lg:overflow-y-auto'
    end

    def vendors_section
      div(class: 'lg:flex-1 lg:min-w-0 lg:flex lg:flex-col', data: { level: 'vendors' }) do
        group_header(title: t('history.index.panel.vendors'), subtitle: nil, group: 'vendors')
        div(class: 'hidden lg:block px-3 pt-3 pb-2') { p(class: 'text-[10px] font-bold uppercase tracking-wider text-slate-500') { t('history.index.panel.vendors') } }
        div(class: group_body_classes) do
          vendor_search
          @facets[:vendors].each_key { |category| vendor_block(category) }
        end
      end
    end

    def vendor_search
      div(class: 'px-3 pt-1 pb-2 hidden', data: { history_filter_panel_target: 'vendorSearch' }) do
        div(class: 'relative') do
          render PhlexIcons::Lucide::Search.new(class: 'absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400 w-3.5 h-3.5')
          input(
            type:        'search',
            placeholder: t('history.index.panel.vendor_search'),
            class:       'w-full bg-slate-50 border border-slate-200 rounded-lg pl-8 pr-3 py-2 text-xs',
            data:        { action: 'input->history-filter-panel#filterVendors' }
          )
        end
      end
    end

    def vendor_block(category)
      div(class: 'hidden', data: { history_filter_panel_target: 'vendorBlock', category: category }) do
        if @facets[:vendors].size > 1
          p(
            class: 'px-3 pt-2 pb-0.5 text-[10px] font-bold uppercase tracking-wider text-slate-400',
            data:  { history_filter_panel_target: 'vendorHeading' }
          ) { category_label(category) }
        end
        @facets[:vendors][category].each { |vendor_data| vendor_row(category, vendor_data) }
      end
    end

    def vendor_row(category, vendor_data)
      vendor = vendor_data[:vendor]
      item_row(
        name:         "vendors[#{category}][]",
        value:        vendor,
        text:         vendor_text(vendor),
        checked:      @slice.vendors[category].to_a.include?(vendor),
        count:        vendor_data[:count],
        total:        vendor_data[:total],
        text_classes: (vendor == History::Slice::NO_VENDOR ? 'italic text-slate-500' : nil)
      )
    end

    def vendor_text(vendor)
      vendor == History::Slice::NO_VENDOR ? t('history.index.panel.no_vendor') : vendor
    end

    def platform_row(platform)
      data = @facets[:platforms][platform]
      item_row(
        name:    'platforms[]',
        value:   platform,
        text:    platform_label(platform),
        checked: @slice.platforms.include?(platform),
        count:   data && data[:count],
        total:   data && data[:total],
        dim:     data.nil?
      ) { platform_lead(platform) }
    end

    def category_row(category)
      data = @facets[:categories][category]
      item_row(
        name:    'categories[]',
        value:   category,
        text:    category_label(category),
        checked: @slice.categories.include?(category),
        count:   data && data[:count],
        total:   data && data[:total],
        dim:     data.nil?
      ) { category_lead(category) }
    end

    def item_row(name:, value:, text:, checked:, count: nil, total: nil, dim: false, text_classes: nil, &lead)
      label(class: class_names(row_classes, dim ? 'opacity-40' : nil)) do
        input(type: 'checkbox', name: name, value: value, checked: checked, class: 'peer sr-only', data: { action: 'change->history-filter-panel#sync' })
        checkbox_box
        lead&.call
        span(class: class_names(row_text_classes, text_classes)) { text }
        count_block(count: count, total: total)
      end
    end

    def row_classes
      'flex items-center gap-3 px-3 min-h-[44px] lg:min-h-0 lg:gap-2.5 lg:py-2 lg:rounded-lg lg:hover:bg-slate-50 cursor-pointer'
    end

    def row_text_classes
      'flex-1 min-w-0 truncate text-sm text-slate-700 peer-checked:font-semibold peer-checked:text-slate-900'
    end

    def checkbox_box
      span(
        class: 'w-5 h-5 rounded-md border bg-white border-slate-300 flex items-center justify-center flex-shrink-0 ' \
               'peer-checked:bg-blue-600 peer-checked:border-blue-600 peer-checked:[&>svg]:opacity-100'
      ) { render PhlexIcons::Lucide::Check.new(class: 'w-[13px] h-[13px] text-white opacity-0', 'stroke-width': '3') }
    end

    def count_block(count:, total: nil)
      return if count.nil?

      span(class: 'text-right leading-tight flex-shrink-0') do
        span(class: 'block text-xs font-semibold text-slate-500 tabular-nums lg:inline') { count.to_s }
        span(class: 'block text-[10px] text-slate-400 tabular-nums lg:inline lg:ml-1') { "· #{format_currency_short(total)}" } if total
      end
    end

    def platform_lead(platform)
      span(
        class: 'w-7 h-7 rounded-md flex items-center justify-center flex-shrink-0 text-[8px] font-bold lg:w-6 lg:h-6 lg:text-[7px]',
        style: "background-color: #{platform_color(platform)}; color: #{platform_fg(platform)};"
      ) { plain platform_label(platform)[0, 4] }
    end

    def category_lead(category)
      span(class: 'w-7 h-7 rounded-md bg-red-50 text-red-600 flex items-center justify-center flex-shrink-0 lg:w-6 lg:h-6') do
        render category_icon(category).new(class: 'w-3.5 h-3.5 lg:w-3 lg:h-3')
      end
    end

    def footer
      div(class: 'flex gap-3 px-4 py-3 bg-white border-t border-slate-200 lg:items-center lg:justify-between lg:bg-slate-50 lg:rounded-b-xl') do
        p(class: 'hidden lg:block text-xs text-slate-500') { t('history.index.panel.period_note', period: period_label) }
        div(class: 'flex gap-3 lg:gap-2') do
          clear_button
          submit_button
        end
      end
    end

    def clear_button
      button(
        type:  'button',
        class: 'px-5 h-11 rounded-xl border text-sm font-semibold border-slate-300 text-slate-700 disabled:border-slate-200 disabled:text-slate-300 ' \
               'lg:px-4 lg:h-auto lg:py-2 lg:rounded-lg lg:bg-white',
        data:  { history_filter_panel_target: 'clear', action: 'history-filter-panel#clear' }
      ) { t('history.index.panel.clear') }
    end

    def submit_button
      button(
        type:  'submit',
        class: 'flex-1 h-11 rounded-xl text-sm font-bold bg-blue-600 text-white shadow-sm shadow-blue-600/20 disabled:bg-slate-200 disabled:text-slate-400 ' \
               'disabled:shadow-none lg:flex-none lg:px-4 lg:h-auto lg:py-2 lg:rounded-lg',
        data:  { history_filter_panel_target: 'submit' }
      ) { t('history.index.panel.submit_all', count: total_count) }
    end

    def period_label
      return @year.to_s if @month.blank?

      "#{I18n.t('date.month_names')[@month].capitalize} #{@year}"
    end

    def category_label(category) = I18n.t("activerecord.attributes.expense.categories.#{category}")
    def platform_label(platform) = I18n.t("activerecord.attributes.earning.platforms.#{platform}")
  end
end
