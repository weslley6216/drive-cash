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

    it 'parses comma decimal with two digits and no thousands' do
      expense = Expense.new

      expense.amount = '12,34'

      expect(expense.amount).to eq(BigDecimal('12.34'))
    end

    it 'parses pt-BR thousands without decimal when the only separator is a dot' do
      expense = Expense.new

      expense.amount = '1.234'

      expect(expense.amount).to eq(BigDecimal('1234'))
    end

    it 'parses multiple pt-BR thousands dots without decimal as an integer' do
      expense = Expense.new

      expense.amount = '1.234.567'

      expect(expense.amount).to eq(BigDecimal('1234567'))
    end
  end

  describe '.monetize on attributes other than amount' do
    it 'normalizes pt-BR decimals on every declared attribute' do
      refueling = Refueling.new

      refueling.total_amount = '1.180,50'
      refueling.liters = '32,5'

      expect(refueling.total_amount).to eq(BigDecimal('1180.50'))
      expect(refueling.liters).to eq(BigDecimal('32.5'))
    end

    it 'treats a comma as the decimal separator even with three digits after it' do
      refueling = Refueling.new

      refueling.liters = '45,678'

      expect(refueling.liters).to eq(BigDecimal('45.678'))
    end
  end
end
