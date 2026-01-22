# app/controllers/expenses_controller.rb
class ExpensesController < ApplicationController
  def index
    @expenses = Expense.chronological
                       .for_year(params[:year])
                       .for_month(params[:month])
                       .by_category(params[:category])
    
    @total = @expenses.sum(:amount)
    @by_category = @expenses.group(:category).sum(:amount)
    
    render Expenses::IndexView.new(
      expenses: @expenses,
      total: @total,
      by_category: @by_category
    )
  end

  def new
    @expense = Expense.new(date: Date.current)

    render Expenses::NewView.new(expense: @expense)
  end

  def create
    @expense = Expense.new(expense_params)

    if @expense.save
      flash.now[:notice] = 'Despesa criada com sucesso!'
      redirect_to expenses_path
    else
      flash.now[:alert] = 'Erro ao criar despesa'
      render Expenses::NewView.new(expense: @expense)
    end
  end

  private

  def expense_params
    params.require(:expense).permit(:date, :amount, :category, :vendor, :description, :notes)
  end
end
