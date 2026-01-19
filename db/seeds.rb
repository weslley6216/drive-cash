ActiveRecord::Base.logger.level = 1

puts "🌱 Iniciando o seed do banco de dados..."

Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |seed|
  filename = File.basename(seed)
  puts "📂 Processando #{filename}..."
  load seed
end

puts "🎉 Todos os seeds foram executados com sucesso!"
