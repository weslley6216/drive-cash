module ComputedStyle
  def emulate_color_scheme(value)
    page.driver.browser.page.command(
      'Emulation.setEmulatedMedia',
      features: [{ name: 'prefers-color-scheme', value: value }]
    )
  end

  def emulate_reduced_motion(value)
    page.driver.browser.page.command(
      'Emulation.setEmulatedMedia',
      features: [{ name: 'prefers-reduced-motion', value: value }]
    )
  end

  def computed(selector, property)
    first(selector, visible: :all).evaluate_script("getComputedStyle(this).#{property}")
  end
end

RSpec.configure do |config|
  config.include ComputedStyle, type: :system
end
