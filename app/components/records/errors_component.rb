module Records
  class ErrorsComponent < ApplicationComponent
    def initialize(record:)
      @record = record
    end

    def view_template
      return unless @record.errors.any?

      div(class: 'rounded-xl border border-red-300 bg-red-50 text-red-700 text-sm px-4 py-3') do
        plain @record.errors.full_messages.to_sentence
      end
    end
  end
end
