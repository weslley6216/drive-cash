module Exports
  class StaleMarker
    def self.call(export:) = new(export: export).call

    def initialize(export:)
      @export = export
    end

    def call
      @export.update(status: :failed) if @export.stale?
      @export
    end
  end
end
