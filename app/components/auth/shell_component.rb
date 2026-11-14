class Auth::ShellComponent < ApplicationComponent
  def initialize(title: nil, subtitle: nil, desktop_subtitle: nil, brand: true, back: false)
    @title = title
    @subtitle = subtitle
    @desktop_subtitle = desktop_subtitle
    @brand = brand
    @back = back
  end

  def view_template(&)
    vanish(&)

    div(class: 'min-h-screen flex bg-white') do
      render Auth::BrandPanelComponent.new
      div(
        class: 'flex-1 flex flex-col px-6 pb-8 bg-gradient-to-br from-slate-50 to-slate-100 ' \
               'lg:items-center lg:justify-center lg:p-8 lg:bg-none lg:bg-slate-50'
      ) do
        div(class: 'w-full flex-1 flex flex-col lg:flex-none lg:max-w-sm') do
          back_block
          header_block
          content_block
          footer_block
        end
      end
    end
  end

  def with_content(&block)
    @content = block
  end

  def with_footer(&block)
    @footer = block
  end

  private

  def back_block
    return unless @back

    div(class: 'pt-1 lg:pt-0 lg:mb-6') { render Auth::BackToLoginComponent.new }
  end

  def header_block
    return unless @brand || @title

    div(class: class_names((@back ? 'pt-4 pb-8' : 'pt-10 pb-8'), 'lg:p-0')) do
      div(class: 'lg:hidden') { render BrandMarkComponent.new(size: :lg) } if @brand
      flash_banner
      title_block
      subtitle_block
    end
  end

  def title_block
    return unless @title

    h1(class: class_names('text-3xl font-bold text-slate-900 tracking-tight', ('mt-8 lg:mt-0' if @brand))) { plain @title }
  end

  def subtitle_block
    return unless @subtitle

    p(class: 'text-sm text-slate-500 mt-2 leading-relaxed') do
      if @desktop_subtitle
        span(class: 'lg:hidden') { plain @subtitle }
        span(class: 'hidden lg:inline') { plain @desktop_subtitle }
      else
        plain @subtitle
      end
    end
  end

  def content_block
    div(class: ('lg:mt-8' if @title)) { render @content }
  end

  def footer_block
    return unless @footer

    div(class: 'mt-auto pt-8 text-center lg:mt-8 lg:pt-0') { render @footer }
  end

  def flash_banner
    if helpers.flash[:notice].present?
      div(class: 'mb-4 rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700') do
        plain helpers.flash[:notice]
      end
    end

    if helpers.flash[:alert].present?
      div(class: 'mb-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700') do
        plain helpers.flash[:alert]
      end
    end
  end
end
