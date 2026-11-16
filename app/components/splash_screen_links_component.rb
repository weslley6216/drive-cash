class SplashScreenLinksComponent < ApplicationComponent
  SCREENS = [
    { width: 440, height: 956, ratio: 3 },
    { width: 430, height: 932, ratio: 3 },
    { width: 428, height: 926, ratio: 3 },
    { width: 420, height: 912, ratio: 3 },
    { width: 414, height: 896, ratio: 3 },
    { width: 414, height: 896, ratio: 2 },
    { width: 414, height: 736, ratio: 3 },
    { width: 402, height: 874, ratio: 3 },
    { width: 393, height: 852, ratio: 3 },
    { width: 390, height: 844, ratio: 3 },
    { width: 375, height: 812, ratio: 3 },
    { width: 375, height: 667, ratio: 2 }
  ].freeze

  def view_template
    SCREENS.each do |screen|
      link(rel: 'apple-touch-startup-image', media: media_query(screen), href: image_path(screen))
    end
  end

  private

  def media_query(screen)
    "(device-width: #{screen[:width]}px) and (device-height: #{screen[:height]}px) " \
      "and (-webkit-device-pixel-ratio: #{screen[:ratio]}) and (orientation: portrait)"
  end

  def image_path(screen)
    "/splash/splash-#{screen[:width] * screen[:ratio]}x#{screen[:height] * screen[:ratio]}.png"
  end
end
