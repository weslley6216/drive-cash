if Rails.env.development?
  ActiveRecord::Base.transaction do
    puts "Limpando banco de dados..."
    Goal.destroy_all
    Earning.destroy_all
    Expense.destroy_all

    dev_user = User.find_or_create_by!(email_address: 'developer@gmail.com') do |user|
      user.name = 'Motorista Dev'
      user.password = '12345678'
      user.password_confirmation = '12345678'
    end

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
          user: dev_user,
          date: date, amount: 180.79, category: :insurance,
          description: 'Seguro Carro - Ituran', vendor: 'Ituran'
        )
        Expense.create!(
          user: dev_user,
          date: date, amount: 34.99, category: :phone,
          description: 'Plano Celular - Claro', vendor: 'Claro'
        )
      end

      if date.day == 10
        Expense.create!(
          user: dev_user,
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
          user: dev_user,
          date: date,
          amount: base_earning,
          platform: PLATFORMS.sample,
          trips_count: rand(8..25),
          notes: "Seed automático"
        )

        Expense.create!(
          user: dev_user,
          date: date,
          amount: random_amount(50, 120),
          category: :fuel,
          description: 'Abastecimento do dia',
          vendor: VENDORS_FUEL.sample
        )

        if rand < 0.6
          Expense.create!(
            user: dev_user,
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
          user: dev_user,
          date: date,
          amount: random_amount(150, 800),
          category: :maintenance,
          description: ['Troca de Óleo', 'Pneus', 'Freios', 'Suspensão', 'Embreagem'].sample,
          vendor: VENDORS_MECH.sample
        )
      end

      if rand < 0.005
        Expense.create!(
          user: dev_user,
          date: date,
          amount: 130.16,
          category: :fine,
          description: 'Multa Velocidade',
          vendor: 'Detran'
        )
      end
    end

    puts "\nCriando metas..."

    Goal.find_or_create_by!(user: dev_user, kind: 'annual', period_start: Date.new(2025, 1, 1)) do |goal|
      goal.target_amount = 70_000.00
      goal.metric       = 'profit'
      goal.period_end   = Date.new(2025, 12, 31)
    end

    Goal.find_or_create_by!(user: dev_user, kind: 'annual', period_start: Date.new(2026, 1, 1)) do |goal|
      goal.target_amount = 80_000.00
      goal.metric       = 'profit'
      goal.period_end   = Date.new(2026, 12, 31)
    end

    {
      1 => 5_500, 2 => 5_500, 3 => 5_800, 4 => 5_800,
      5 => 6_000, 6 => 6_000, 7 => 6_200, 8 => 6_200,
      9 => 6_200, 10 => 6_500, 11 => 6_500, 12 => 6_800
    }.each do |month, target|
      start_date = Date.new(2025, month, 1)
      Goal.find_or_create_by!(user: dev_user, kind: 'monthly', period_start: start_date) do |goal|
        goal.target_amount = target
        goal.metric       = 'profit'
        goal.period_end   = start_date.end_of_month
      end
    end

    {
      1 => 6_500, 2 => 6_500, 3 => 6_800,
      4 => 6_500, 5 => 7_000, 6 => 7_000
    }.each do |month, target|
      start_date = Date.new(2026, month, 1)
      Goal.find_or_create_by!(user: dev_user, kind: 'monthly', period_start: start_date) do |goal|
        goal.target_amount = target
        goal.metric       = 'profit'
        goal.period_end   = start_date.end_of_month
      end
    end

    [
      [Date.new(2026, 4, 28), Date.new(2026, 5, 4),  1_500],
      [Date.new(2026, 5, 5),  Date.new(2026, 5, 11), 1_500],
      [Date.new(2026, 5, 12), Date.new(2026, 5, 18), 1_600],
      [Date.new(2026, 5, 19), Date.new(2026, 5, 25), 1_600],
      [Date.new(2026, 5, 26), Date.new(2026, 6, 1),  1_600],
      [Date.new(2026, 6, 1),  Date.new(2026, 6, 7),  1_700],
      [Date.new(2026, 6, 8),  Date.new(2026, 6, 14), 1_700],
      [Date.new(2026, 6, 15), Date.new(2026, 6, 21), 1_700],
      [Date.new(2026, 6, 22), Date.new(2026, 6, 28), 1_700]
    ].each do |period_start, period_end, target|
      Goal.find_or_create_by!(user: dev_user, kind: 'weekly', period_start: period_start) do |goal|
        goal.target_amount = target
        goal.metric       = 'profit'
        goal.period_end   = period_end
      end
    end

    puts "\nGarantindo conquistas da tela de Metas..."

    # Remove random earnings for June 3-9 so fixed amounts are exact
    Earning.where(user: dev_user, date: Date.new(2026, 6, 3)..Date.new(2026, 6, 9)).delete_all

    # Sequência 7 dias (flame) + Melhor dia R$ 580 em 3/jun (zap)
    {
      Date.new(2026, 6, 3) => 580.00,
      Date.new(2026, 6, 4) => 290.00,
      Date.new(2026, 6, 5) => 310.00,
      Date.new(2026, 6, 6) => 270.00,
      Date.new(2026, 6, 7) => 250.00,
      Date.new(2026, 6, 8) => 330.00,
      Date.new(2026, 6, 9) => 300.00
    }.each do |date, amount|
      Earning.create!(user: dev_user, date: date, amount: amount, platform: :uber, trips_count: rand(10..18))
    end

    # Meta de Maio batida (star/roxo): garante lucro > R$ 7.000 (target de maio)
    [Date.new(2026, 5, 6), Date.new(2026, 5, 13), Date.new(2026, 5, 20), Date.new(2026, 5, 27)].each do |date|
      Earning.create!(user: dev_user, date: date, amount: 1_500.00, platform: :uber, trips_count: rand(20..25))
    end

    # Meta de Abril batida também: garante lucro > R$ 6.500 (target de abril)
    [Date.new(2026, 4, 7), Date.new(2026, 4, 14), Date.new(2026, 4, 21), Date.new(2026, 4, 28)].each do |date|
      Earning.create!(user: dev_user, date: date, amount: 1_500.00, platform: :uber, trips_count: rand(20..25))
    end
  end

  puts "\nSeed concluído com sucesso!"
  puts "Resumo:"
  puts "   Ganhos: #{Earning.count}"
  puts "   Despesas: #{Expense.count}"
  puts "   Metas: #{Goal.count}"
end
