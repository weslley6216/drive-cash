module Chat
  module ConfirmChips
    Chip = Data.define(:route, :label, :frame)

    SPECS = {
      'create_earning' => [
        Chip.new(route: :root_path, label: 'chat.confirm.btn_dashboard', frame: '_top'),
        Chip.new(route: :dashboard_earnings_detail_path, label: 'chat.confirm.btn_earnings', frame: 'modal')
      ],
      'create_expense' => [
        Chip.new(route: :dashboard_expenses_detail_path, label: 'chat.confirm.btn_expenses', frame: 'modal'),
        Chip.new(route: :root_path, label: 'chat.confirm.btn_home', frame: '_top')
      ]
    }.freeze

    DEFAULT = [Chip.new(route: :root_path, label: 'chat.confirm.btn_home', frame: '_top')].freeze

    def self.for(action) = SPECS.fetch(action, DEFAULT)
  end
end
