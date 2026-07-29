module Exports
  class CreateView < ApplicationView
    def initialize(export:)
      @export = export
    end

    def view_template
      raw turbo_stream.remove('export-recents-empty')
      raw turbo_stream.prepend('export-recents') { render Exports::RecentRowView.new(export: @export) }
      raw turbo_stream.replace('export-wait') { render Exports::WaitComponent.new(export: @export) }
    end
  end
end
