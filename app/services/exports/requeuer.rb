module Exports
  class Requeuer
    def self.call(export:) = new(export: export).call

    def initialize(export:)
      @export = export
    end

    def call
      return @export unless @export.status_failed?

      @export.update!(status: :pending)
      ExportJob.perform_later(@export.id)
      @export
    end
  end
end
