module Earnings
  class IndexView < ApplicationComponent
    def initialize(earnings:, total:)
      @earnings = earnings
      @total = total
    end

    def view_template
      render LayoutComponent.new(title: 'Receitas') do
        h1(class: 'text-3xl font-bold mb-6') { 'Minhas Receitas' }
        
        div(class: 'bg-green-50 border-2 border-green-200 rounded-lg p-4 mb-6') do
          p(class: 'text-sm text-green-700') { 'Total' }
          p(class: 'text-3xl font-bold text-green-900') { format_currency(@total) }
        end
        
        div(class: 'space-y-4') do
          @earnings.each do |earning|
            earning_card(earning)
          end
        end
      end
    end

    private

    def earning_card(earning)
      div(class: 'bg-white rounded-lg p-4 shadow') do
        div(class: 'flex justify-between items-center') do
          div do
            p(class: 'font-bold') { format_currency(earning.amount) }
            p(class: 'text-sm text-gray-600') { l(earning.date) }
          end
          span(class: 'text-sm bg-green-100 text-green-800 px-2 py-1 rounded') do
            earning.platform
          end
        end
      end
    end
  end
end
