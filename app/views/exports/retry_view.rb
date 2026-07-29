module Exports
  class RetryView < ApplicationView
    def initialize(export:)
      @export = export
    end

    def view_template
      raw turbo_stream.replace("export_#{@export.id}") { render Exports::RecentRowView.new(export: @export) }
    end
  end
end
