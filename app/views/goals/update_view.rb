module Goals
  class UpdateView < ApplicationView
    include TurboSaveStreams

    def initialize(goal:)
      @goal = goal
    end

    def view_template
      clear_modal_stream
      flash_stream
    end
  end
end
