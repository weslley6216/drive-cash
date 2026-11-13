class ScreenComponent < ApplicationComponent
  FRAME = 'flex-1 flex flex-col min-h-0 safe-top sm:pt-0'.freeze
  CONTENT = 'flex-1 min-h-0 overflow-y-auto px-5 sm:px-6 pb-3.5 lg:px-0 lg:pb-8'.freeze

  def initialize(frame: false, inline_header: false)
    @frame = frame
    @inline_header = inline_header
  end

  def view_template(&)
    vanish(&)

    if @frame
      turbo_frame_tag('page', class: FRAME) { screen }
    else
      div(class: FRAME) { screen }
    end
  end

  def with_header(&block)
    @header = block
  end

  def with_content(&block)
    @content = block
  end

  private

  def screen
    div(id: 'flash', class: 'flex-none') { render FlashComponent.new(flash: helpers.flash) }
    div(id: 'screen-header', class: 'flex-none') { render @header } if @header
    @frame ? loading_region : content_region
  end

  def loading_region
    div(class: 'feed-loading-region flex-1 flex flex-col min-h-0') do
      div(class: 'feed-loading-overlay') do
        div(class: 'w-8 h-8 rounded-full border-4 border-slate-100 border-t-blue-600 animate-spin')
      end
      content_region
    end
  end

  def content_region
    div(id: 'screen-content', class: class_names(CONTENT, ('lg:pt-8' unless @inline_header))) { render @content }
  end
end
