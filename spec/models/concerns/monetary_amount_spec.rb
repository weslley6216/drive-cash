require 'rails_helper'

RSpec.describe MonetaryAmount, type: :model do
  describe '#amount=' do
    it 'parses pt-BR thousands with decimal' do
      expense = Expense.new

      expense.amount = '1.234,56'

      expect(expense.amount).to eq(BigDecimal('1234.56'))
    end

    it 'parses multiple pt-BR thousands separators' do
      expense = Expense.new

      expense.amount = '1.234.567,89'

      expect(expense.amount).to eq(BigDecimal('1234567.89'))
    end

    it 'parses comma decimal without thousands' do
      expense = Expense.new

      expense.amount = '1234,56'

      expect(expense.amount).to eq(BigDecimal('1234.56'))
    end

    it 'parses dot decimal without thousands' do
      expense = Expense.new

      expense.amount = '1234.56'

      expect(expense.amount).to eq(BigDecimal('1234.56'))
    end

    it 'strips currency symbol and whitespace' do
      expense = Expense.new

      expense.amount = 'R$ 50,00'

      expect(expense.amount).to eq(BigDecimal('50.00'))
    end

    it 'parses integer string' do
      expense = Expense.new

      expense.amount = '50'

      expect(expense.amount).to eq(BigDecimal('50'))
    end

    it 'passes Numeric through unchanged' do
      expense = Expense.new

      expense.amount = 123.45

      expect(expense.amount).to eq(BigDecimal('123.45'))
    end

    it 'passes BigDecimal through unchanged' do
      expense = Expense.new

      expense.amount = BigDecimal('99.99')

      expect(expense.amount).to eq(BigDecimal('99.99'))
    end

    it 'passes nil through unchanged' do
      expense = Expense.new

      expense.amount = nil

      expect(expense.amount).to be_nil
    end

    it 'parses pt-BR thousands without decimal as integer' do
      expense = Expense.new

      expense.amount = '1.500'

      expect(expense.amount).to eq(BigDecimal('1500'))
    end

    it 'parses large pt-BR thousands without decimal as integer' do
      expense = Expense.new

      expense.amount = '100.000'

      expect(expense.amount).to eq(BigDecimal('100000'))
    end
  end
end
