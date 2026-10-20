require "minitest/autorun"
require "slugify"

class SlugifyTest < Minitest::Test
  def test_spaces_become_hyphens
    assert_equal "hello-world", Slugify.call("Hello World")
  end

  def test_punctuation_is_dropped_and_trimmed
    assert_equal "rails-8-1-what-s-new", Slugify.call("  Rails 8.1: What's New?  ")
  end

  def test_repeated_separators_collapse
    assert_equal "a-b", Slugify.call("a -- b")
  end

  def test_accents_are_transliterated
    assert_equal "creme-brulee", Slugify.call("Crème brûlée")
  end
end
