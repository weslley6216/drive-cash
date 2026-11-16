module Goals
  module Achievements
    def self.present(raw)
      const_get(raw[:type].to_s.camelize, false).new(raw).call
    end
  end
end
