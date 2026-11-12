module Dashboard
  class CategoryBreakdownService < BreakdownService
    def initialize(ledger: nil, **)
      super(**)
      @ledger = ledger || YearLedger.new(user: user, year: year)
    end

    private

    attr_reader :ledger

    def default_limit = 5

    def aggregates
      ledger.spent_by_category(month).map { |category, amount| { id: category, amount: amount } }
    end

    def build_row(row)
      {
        id:      row[:id],
        label:   I18n.t("activerecord.attributes.expense.categories.#{row[:id]}"),
        amount:  row[:amount],
        percent: percent(row[:amount])
      }
    end
  end
end
