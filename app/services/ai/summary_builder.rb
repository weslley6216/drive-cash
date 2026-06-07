module Ai
  class SummaryBuilder
    include Formatting

    def self.build(action, params)
      new(action, params).call
    end

    def initialize(action, params)
      @action = action
      @params = params || {}
    end

    def call
      case @action
      when 'create_earning' then earning_summary
      when 'create_expense' then expense_summary
      else I18n.t('chat.message.fallback')
      end
    end

    private

    def earning_summary
      platform = I18n.t("activerecord.attributes.earning.platforms.#{@params['platform']}",
                        default: @params['platform'].to_s.capitalize)
      I18n.t('chat.preview.earning',
             amount: format_currency(@params['amount']),
             platform: platform,
             date: format_date(@params['date']))
    end

    def expense_summary
      category = I18n.t("activerecord.attributes.expense.categories.#{@params['category']}",
                        default: @params['category'].to_s.capitalize)
      vendor = @params['vendor'].present? ? " — #{@params['vendor']}" : ''
      base = I18n.t('chat.preview.expense',
                    amount: format_currency(@params['amount']),
                    category: category,
                    vendor: vendor,
                    date: format_date(@params['date']))

      installments = installments_count
      period = (@params['installments_period'].presence || @params['installment_period']).to_s
      return base if installments < 2 || !Expense::INSTALLMENT_PERIODS.include?(period)

      period_label = I18n.t("expenses.period_labels.#{period}", default: period)
      I18n.t('chat.preview.expense_installments',
             base: base,
             installments: installments,
             period: period_label)
    end

    def installments_count
      raw_value = @params['installments'] || @params['installment_count']
      raw_value.respond_to?(:to_i) ? raw_value.to_i : 0
    end

    def format_date(date_str)
      Date.parse(date_str.to_s).strftime('%d/%m/%Y')
    rescue ArgumentError
      date_str.to_s
    end
  end
end
