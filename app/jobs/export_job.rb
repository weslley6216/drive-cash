class ExportJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS = 3

  retry_on StandardError, wait: :polynomially_longer, attempts: MAX_ATTEMPTS do |job, error|
    Export.find_by(id: job.arguments.first)&.update(status: :failed)
    raise error
  end

  discard_on ActiveRecord::RecordNotFound

  def perform(export_id)
    export = Export.find(export_id)
    export.update!(status: :processing)

    payload = Exports::Builder.call(export: export)
    generator = Exports::Registry.for(export.format)
    file = generator.call(payload: payload)

    export.file.attach(io: file.io, filename: file.filename, content_type: file.content_type)
    export.update!(status: :done)
  end
end
