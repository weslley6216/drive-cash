module Phone
  WIDTH = 390
  HEIGHT = 844

  def emulate_phone(width: WIDTH, height: HEIGHT)
    browser_page = page.driver.browser.page
    browser_page.set_viewport(width: width, height: height, scale_factor: 2, mobile: true)
    browser_page.command('Emulation.setTouchEmulationEnabled', enabled: true, maxTouchPoints: 5)
  end

  def emulate_desktop_screen(width: 1280, height: 800)
    page.driver.resize(width, height)
    page.driver.browser.page.command('Emulation.setTouchEmulationEnabled', enabled: false)
  end
end

RSpec::Matchers.define :fit_the_phone_width do
  match { |session| session.evaluate_script('document.documentElement.scrollWidth <= screen.width') }

  failure_message do |session|
    width = session.evaluate_script('document.documentElement.scrollWidth')
    screen = session.evaluate_script('screen.width')
    "expected the page to fit the #{screen}px phone screen, but it is #{width}px wide"
  end
end

RSpec.configure do |config|
  config.include Phone, type: :system
end
