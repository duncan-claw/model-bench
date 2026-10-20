# Turns arbitrary text into a URL slug.
module Slugify
  def self.call(text)
    text.downcase.gsub(" ", "-")
  end
end
