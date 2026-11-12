module ScreenGeometry
  SHORT_PHONE_HEIGHT = 360

  def box(element)
    element.evaluate_script('this.getBoundingClientRect().toJSON()')
  end

  def emulate_short_phone
    emulate_phone(height: SHORT_PHONE_HEIGHT)
  end

  def screen_content_scroll_top
    page.evaluate_script("document.getElementById('screen-content').scrollTop")
  end
end

RSpec::Matchers.define :stay_pinned_while_the_content_scrolls do
  chain(:in) { |selector| @scroller = selector }

  match do |element|
    session = element.session
    scroller = "document.querySelector('#{@scroller || '#screen-content'}')"
    @top_before = element.evaluate_script('this.getBoundingClientRect().top')
    session.execute_script("#{scroller}.scrollTop = 100000")
    @content_scroll = session.evaluate_script("#{scroller}.scrollTop")
    @window_scroll = session.evaluate_script('window.scrollY')
    @top_after = element.evaluate_script('this.getBoundingClientRect().top')
    @content_scroll.positive? && @window_scroll.zero? && @top_after == @top_before
  end

  failure_message do
    "expected the header to stay at #{@top_before}px while #{@scroller || '#screen-content'} scrolled, but the content " \
      "scrolled #{@content_scroll}px, the window #{@window_scroll}px and the header ended at #{@top_after}px"
  end
end

RSpec.configure do |config|
  config.include ScreenGeometry, type: :system
end
