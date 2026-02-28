module ModalHeader
  def render_header(subtitle: nil)
    div(class: "#{modal_header_classes} #{theme_styles(@theme)[:header_border]}") do
      header_content(subtitle)
      close_button
    end
  end

  private

  def header_content(subtitle)
    div(class: 'min-w-0 flex-1') do
      h2(class: "#{modal_title_classes} #{title_classes(theme: @theme)} truncate") { t('.title') }
      p(class: 'text-xs text-slate-500 mt-0.5') { subtitle } if subtitle
    end
  end

  def close_button
    button(type: 'button', data: { action: 'modal#close' },
           class: "#{modal_close_button_classes} #{theme_styles(@theme)[:close_button]}") do
      render PhlexIcons::Lucide::X.new(class: 'w-6 h-6')
    end
  end
end
