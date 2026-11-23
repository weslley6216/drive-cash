module Chat
  PreviewQueue = Data.define(:previews, :batch_size) do
    PREVIEW_KEYS = %i[type action params summary content text_before].freeze

    def self.from_result(result)
      return new(previews: [], batch_size: 0) unless result[:type] == :preview

      previews = [result.except(:queued), *Array(result[:queued])].map { |preview| preview.slice(*PREVIEW_KEYS).compact }

      new(previews: previews, batch_size: previews.size)
    end

    def self.from_session(hash)
      return new(previews: [], batch_size: 0) if hash.blank?

      previews = hash['previews'].map { |preview| preview.symbolize_keys.merge(type: :preview) }

      new(previews: previews, batch_size: hash['batch_size'])
    end

    def head = previews.first

    def advance = with(previews: previews.drop(1))

    def empty? = previews.empty?

    def batch? = batch_size >= 2

    def to_session_hash
      { 'previews' => previews, 'batch_size' => batch_size }
    end
  end
end
