class Passwords::NewView < ApplicationView
  def view_template
    render LayoutComponent.new(title: t('.title'), auth: true) do
      render Auth::ShellComponent.new(title: t('.heading'), subtitle: t('.subtitle'), brand: false, back: true) do |shell|
        shell.with_content { content_block }
      end
    end
  end

  private

  def content_block
    form_with(url: helpers.passwords_path, data: { turbo: false }, class: 'space-y-4') do |form|
      render Auth::FieldComponent.new(
        form: form, attribute: :email_address, label: t('.email'), icon: PhlexIcons::Lucide::Mail,
        type: :email, autocomplete: 'email', autofocus: true
      )
      div(class: 'pt-1') { render Auth::CtaComponent.new(label: t('.submit'), icon: PhlexIcons::Lucide::Send) }
    end
  end
end
