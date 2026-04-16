module HolidaysRest
  Holiday = Data.define(:name, :date, :type, :country, :region, :religion, :language) do
    def self.from_hash(h)
      new(
        name:     h.fetch("name", ""),
        date:     h.fetch("date", ""),
        type:     h.fetch("type", ""),
        country:  h.fetch("country", ""),
        region:   h.fetch("region", ""),
        religion: h.fetch("religion", ""),
        language: h.fetch("language", "")
      )
    end
  end

  Subdivision = Data.define(:code, :name) do
    def self.from_hash(h)
      new(code: h.fetch("code", ""), name: h.fetch("name", ""))
    end
  end

  Country = Data.define(:name, :alpha2, :subdivisions) do
    def self.from_hash(h)
      new(
        name:         h.fetch("name", ""),
        alpha2:       h.fetch("alpha2", ""),
        subdivisions: Array(h["subdivisions"]).map { Subdivision.from_hash(_1) }
      )
    end
  end

  Language = Data.define(:code, :name) do
    def self.from_hash(h)
      new(code: h.fetch("code", ""), name: h.fetch("name", ""))
    end
  end
end
