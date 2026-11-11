require 'rails_helper'

RSpec.describe UndoToastComponent, type: :component do
  describe '#view_template' do
    it 'renders the message and an undo form' do
      payload = {
        'category' => 'oil_change',
        'km'       => 160_928,
        'count'    => 3,
        'path'     => '/maintenances/5/mark_done',
        'restore'  => { '12' => 155_600 }
      }

      html = view_context.render(described_class.new(payload: payload))

      expect(html).to include('Troca de óleo feita aos 160.928 km · 3 itens atualizados')
      expect(html).to include('name="_method"').and include('value="delete"')
      expect(html).to include('name="restore[12]"').and include('value="155600"')
      expect(html).to include('bg-slate-900')
      expect(html).to include('data-flash-delay-value="6000"')
    end
  end
end
