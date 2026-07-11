require 'rails_helper'

RSpec.describe Chat::ConfirmView, type: :component do
  it 'renders the home chip as the fallback for an unknown action' do
    output = view_context.render(
      described_class.new(
        success: true,
        message: 'Registrado',
        action:  'unknown_action',
        date:    Date.new(2026, 4, 22)
      )
    )

    expect(output).to include(I18n.t('chat.confirm.btn_home'))
  end
end
