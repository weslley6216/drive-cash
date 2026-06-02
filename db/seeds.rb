if Rails.env.development?
  ActiveRecord::Base.transaction do
    puts "Limpando banco de dados..."
    Earning.destroy_all
    Expense.destroy_all

    PLATFORMS = [:shopee, :mercado_livre, :ifood, :uber, :rappi]

    VENDORS_MECH = ['Carmaniacs', 'Auto Peças Castelo', 'Baterias Rainha', 'Zé Pneus']
    VENDORS_FUEL = ['Posto Ipiranga', 'Posto Shell', 'Posto BR', 'Posto Ale']
    VENDORS_FOOD = ['Restaurante da Dona Maria', 'McDonalds', 'Subway', 'Marmitaria']

    def random_amount(min, max)
      rand(min..max).round(2)
    end

    puts "Iniciando o seed (2025-2026)..."

    (Date.new(2025, 1, 1)..Date.new(2026, 12, 31)).each do |date|
      print "." if date.day == 1
      puts " Mês #{date.month}/#{date.year}" if date.day == 1

      if date.day == 5
        Expense.create!(
          date: date, amount: 180.79, category: :insurance,
          description: 'Seguro Carro - Ituran', vendor: 'Ituran'
        )
        Expense.create!(
          date: date, amount: 34.99, category: :phone,
          description: 'Plano Celular - Claro', vendor: 'Claro'
        )
      end

      if date.day == 10
        Expense.create!(
          date: date, amount: 27.86, category: :insurance,
          description: 'Seguro Celular - Pier', vendor: 'Pier'
        )
      end

      is_working_day = !date.sunday? || (date.sunday? && rand < 0.2)

      if is_working_day
        growth_factor = 1.0 + ((date.year - 2025) * 0.15)
        base_earning = random_amount(220, 400) * growth_factor
        base_earning += 150 if rand < 0.1

        Earning.create!(
          date: date,
          amount: base_earning,
          platform: PLATFORMS.sample,
          trips_count: rand(8..25),
          notes: "Seed automático"
        )

        Expense.create!(
          date: date,
          amount: random_amount(50, 120),
          category: :fuel,
          description: 'Abastecimento do dia',
          vendor: VENDORS_FUEL.sample
        )

        if rand < 0.6
          Expense.create!(
            date: date,
            amount: random_amount(25, 45),
            category: :meals,
            description: 'Almoço na rota',
            vendor: VENDORS_FOOD.sample
          )
        end
      end

      if rand < 0.015
        Expense.create!(
          date: date,
          amount: random_amount(150, 800),
          category: :maintenance,
          description: ['Troca de Óleo', 'Pneus', 'Freios', 'Suspensão', 'Embreagem'].sample,
          vendor: VENDORS_MECH.sample
        )
      end

      if rand < 0.005
        Expense.create!(
          date: date,
          amount: 130.16,
          category: :fine,
          description: 'Multa Velocidade',
          vendor: 'Detran'
        )
      end
    end
  end

  puts "\nSeed concluído com sucesso!"
  puts "Resumo:"
  puts "   Ganhos: #{Earning.count}"
  puts "   Despesas: #{Expense.count}"
end
