require 'prawn'
require 'prawn/table'

module Exports
  module Generators
    class Pdf
      File = Data.define(:io, :filename, :content_type)

      def self.call(payload:)
        new(payload: payload).call
      end

      def initialize(payload:)
        @payload = payload
      end

      def call
        document = Prawn::Document.new(margin: 36)
        render_header(document)
        render_section(document, 'Receitas', earning_table)
        render_section(document, 'Despesas', expense_table)
        render_section(document, 'Abastecimentos', refueling_table)
        render_section(document, 'Manutenções', maintenance_table)
        render_totals(document)

        io = StringIO.new(document.render)
        File.new(io: io, filename: "drivecash-export-#{Time.current.to_i}.pdf", content_type: 'application/pdf')
      end

      private

      def render_header(document)
        document.text 'Relatório DriveCash', size: 18, style: :bold
        document.move_down 6
        document.text "Gerado em #{I18n.l(Time.current, format: :long)}", size: 10
        document.move_down 16
      end

      def render_section(document, label, table_data)
        return if table_data.size <= 1

        document.text label, size: 13, style: :bold
        document.move_down 4
        document.table(table_data, header: true, cell_style: { size: 9, padding: 4 }) do
          row(0).font_style = :bold
          row(0).background_color = 'EEEEEE'
        end
        document.move_down 14
      end

      def earning_table
        rows = @payload.earnings.map do |earning|
          [I18n.l(earning[:date]), earning[:platform], format('%.2f', earning[:amount]), earning[:trips_count].to_s]
        end

        [%w[Data Plataforma Valor Corridas]] + rows
      end

      def expense_table
        rows = @payload.expenses.map do |expense|
          [I18n.l(expense[:date]), expense[:category], expense[:vendor].to_s, format('%.2f', expense[:amount])]
        end

        [%w[Data Categoria Vendor Valor]] + rows
      end

      def refueling_table
        rows = @payload.refuelings.map do |refueling|
          [I18n.l(refueling[:date]), refueling[:vendor].to_s, refueling[:liters].to_s, format('%.2f', refueling[:total_amount])]
        end

        [%w[Data Posto Litros Valor]] + rows
      end

      def maintenance_table
        rows = @payload.maintenances.map do |maintenance|
          [maintenance[:category], maintenance[:interval_km].to_s, maintenance[:last_done_km].to_s]
        end

        [%w[Tipo Intervalo\ km Última\ km]] + rows
      end

      def render_totals(document)
        document.text 'Totais', size: 13, style: :bold
        document.move_down 4
        rows = [
          ['Receitas', format('R$ %.2f', @payload.totals[:earnings])],
          ['Despesas', format('R$ %.2f', @payload.totals[:expenses])],
          ['Lucro líquido', format('R$ %.2f', @payload.totals[:profit])],
          ['Lançamentos', @payload.totals[:count].to_s]
        ]
        document.table(rows, cell_style: { size: 10, padding: 4 })
      end
    end
  end
end
