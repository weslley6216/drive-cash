module History
  module EntryRows
    def self.for(record)
      "History::EntryRows::#{record.class.name}".constantize.new(record)
    end
  end
end
