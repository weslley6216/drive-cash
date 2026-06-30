class ExportJob < ApplicationJob
  queue_as :default

  def perform(export_id)
    export = Export.find(export_id)
    export.update!(status: :processing)

    payload = Exports::Builder.call(export: export)
    generator = Exports::Registry.for(export.format)
    file = generator.call(payload: payload)

    export.file.attach(io: file.io, filename: file.filename, content_type: file.content_type)
    export.update!(status: :done)
  rescue StandardError
    export&.update(status: :failed)
    raise
  end
end
