module HolidaysRest
  HolidayDay = Data.define(:actual, :observed) do
    def self.from_hash(h)
      new(
        actual:   h.fetch("actual", ""),
        observed: h.fetch("observed", "")
      )
    end
  end

  Holiday = Data.define(:country_code, :country_name, :date, :name,
                        :is_national, :is_religious, :is_local, :is_estimate,
                        :day, :religion, :regions) do
    def self.from_hash(h)
      new(
        country_code: h.fetch("country_code", ""),
        country_name: h.fetch("country_name", ""),
        date:         h.fetch("date", ""),
        name:         h.fetch("name", {}),
        is_national:  h.fetch("isNational", false),
        is_religious: h.fetch("isReligious", false),
        is_local:     h.fetch("isLocal", false),
        is_estimate:  h.fetch("isEstimate", false),
        day:          HolidayDay.from_hash(h.fetch("day", {})),
        religion:     h.fetch("religion", ""),
        regions:      Array(h["regions"])
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
