if Rails.env.development?
  puts "🧹 Limpando banco de dados para testes..."
  Earning.destroy_all
  Expense.destroy_all
  Trip.destroy_all

  PLATFORMS = ['shopee', 'mercado_livre', 'ifood']
  VENDORS_MECH = ['Carmaniacs', 'Auto Peças Castelo', 'Baterias Rainha', 'Zé Pneus']
  VENDORS_FUEL = ['Posto Ipiranga', 'Posto Shell', 'Posto BR']

  def random_amount(min, max)
    rand(min..max).round(2)
  end

  (Date.new(2025, 1, 1)..Date.new(2026, 12, 31)).each do |date|
    
    if date.day == 5
      trip = Trip.find_or_create_by!(date: date)
      Expense.create!(
        trip: trip, date: date, amount: 180.79, category: 'insurance', 
        description: 'Seguro Carro - Ituran', vendor: 'Ituran'
      )
      Expense.create!(
        trip: trip, date: date, amount: 34.99, category: 'phone', 
        description: 'Plano Celular - Claro', vendor: 'Claro'
      )
    end

    if date.day == 10
      trip = Trip.find_or_create_by!(date: date)
      Expense.create!(
        trip: trip, date: date, amount: 27.86, category: 'insurance', 
        description: 'Seguro Celular - Pier', vendor: 'Pier'
      )
    end

    is_working_day = !date.sunday? || (date.sunday? && rand < 0.2)

    if is_working_day
      trip = Trip.find_or_create_by!(date: date)

      growth_factor = 1.0 + ((date.year - 2024) * 0.1) 
      base_earning = random_amount(220, 400) * growth_factor
      
      base_earning += 200 if rand < 0.1

      Earning.create!(
        trip: trip,
        date: date,
        amount: base_earning,
        platform: PLATFORMS.sample,
        notes: "Seed automático"
      )

      fuel_amount = random_amount(35, 80)
      Expense.create!(
        trip: trip,
        date: date,
        amount: fuel_amount,
        category: 'fuel',
        description: 'Abastecimento do dia',
        vendor: VENDORS_FUEL.sample
      )

      if rand < 0.4
        Expense.create!(
          trip: trip,
          date: date,
          amount: random_amount(25, 40),
          category: 'food',
          description: 'Almoço na rota',
          vendor: 'Restaurante'
        )
      end
    end

    if rand < 0.015 
      trip = Trip.find_or_create_by!(date: date)
      cost = random_amount(150, 800)
      Expense.create!(
        trip: trip,
        date: date,
        amount: cost,
        category: 'maintenance',
        description: ['Troca de Óleo', 'Pneus', 'Freios', 'Suspensão'].sample,
        vendor: VENDORS_MECH.sample
      )
      puts "🔧 Manutenção simulada em #{date}: R$ #{cost}"
    end

    if rand < 0.005
      trip = Trip.find_or_create_by!(date: date)
      Expense.create!(
        trip: trip,
        date: date,
        amount: 130.16,
        category: 'fine',
        description: 'Multa Velocidade',
        vendor: 'Detran'
      )
    end
  end

  puts "✅ Seed concluído!"
  puts "📅 Período: 2025 a 2026"
  puts "📊 Trips: #{Trip.count} | Earnings: #{Earning.count} | Expenses: #{Expense.count}"
end
