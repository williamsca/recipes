require "minitest/autorun"
require "yaml"

# This checks recipe source data only; it has no dependency on Jekyll or layouts.
module IngredientUnits
  ALIASES = {
    "cup" => %w[c cups],
    "tsp" => %w[t teaspoon teaspoons tsps],
    "tbsp" => %w[tablespoon tablespoons tbs tbsps tbl tbls],
    "oz" => %w[ounce ounces ozs],
    "lb" => %w[pound pounds lbs],
    "g" => %w[gram grams gm gms gr],
    "kg" => %w[kilogram kilograms kgs],
    "ml" => %w[milliliter milliliters millilitre millilitres mls],
    "l" => %w[liter liters litre litres],
    "pint" => %w[pt pts pints],
    "quart" => %w[qt qts quarts],
    "gallon" => %w[gal gals gallons]
  }.freeze
  CANONICAL = ALIASES.each_with_object({}) do |(unit, variants), result|
    ([unit] + variants).each { |variant| result[variant] = unit }
  end.freeze
  # Cups, pints, quarts and gallons may retain their natural plural forms.
  ACCEPTED = (ALIASES.keys + %w[cups pints quarts gallons]).freeze
  TOKEN = /(?<![[:alpha:]_])(?:#{CANONICAL.keys.sort_by { |s| -s.length }.join("|")}|T)\.?(?![[:alpha:]_])/i

  def self.violations(line)
    # Link labels can contain measurements; link destinations are not ingredients.
    text = line.gsub(/\[([^\]]+)\]\([^)]*\)/, '\1')
    errors = []
    text.to_enum(:scan, TOKEN).each do
      match = Regexp.last_match
      token = match[0]
      bare = token.delete_suffix(".")
      prefix = text[0...match.begin(0)]
      # Single-letter cooking shorthand is meaningful only after a quantity.
      next if %w[c t T].include?(bare) && !prefix.match?(/[\d¼½¾⅐-⅞]\s*[-–—]?\s*\z/)

      expected = bare == "T" ? "tbsp" : CANONICAL.fetch(bare.downcase)
      errors << "use #{expected.inspect} instead of #{token.inspect}" unless ACCEPTED.include?(token)
      if prefix.match?(/[\d¼½¾⅐-⅞]\z/)
        errors << "add a space before #{token.inspect} (for example, 250 g)"
      end
    end
    errors
  end
end

class RecipeIngredientUnitsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  RECIPES = Dir[File.join(ROOT, "_recipes", "**", "*.md")].sort.freeze

  def test_recipes_are_discovered
    refute_empty RECIPES, "No recipe Markdown files found"
  end

  RECIPES.each do |path|
    define_method("test_units_in_#{File.basename(path, '.md')}") do
      source = File.read(path)
      front_matter = source.match(/\A---\s*\n(.*?)^---\s*$/m)
      refute_nil front_matter, "#{path}: missing YAML front matter"
      data = YAML.safe_load(front_matter[1])
      ingredients = data.fetch("ingredients") { flunk "#{path}: missing ingredients field; unit checks cannot run" }
      assert_kind_of String, ingredients, "#{path}: ingredients must be a Markdown string"
      refute_empty ingredients.strip, "#{path}: ingredients is empty; unit checks cannot run"

      entries = ingredients.lines.each_with_index.select { |line, _| line.match?(/^\s*[-*+]\s+\S/) }
      refute_empty entries, "#{path}: no ingredient list entries found; unit checks cannot run"
      errors = entries.flat_map do |line, index|
        IngredientUnits.violations(line).map do |error|
          "#{path}: ingredients line #{index + 1}: #{error}\n  #{line.strip}"
        end
      end
      assert errors.empty?, errors.join("\n")
    end
  end
end

class IngredientUnitCheckerTest < Minitest::Test
  def test_accepts_standard_units_and_common_quantity_formats
    ["1 cup flour", "2 cups flour", "½ tsp salt", "1½ tbsp oil", "1 1/2 lb chicken",
     "12–14 oz sausage", "250 g flour", "1 (28-oz) can tomatoes", "2 l stock",
     "1/4 cup (4 tbsp) butter", "4¼ cups/1 l wine", "2 quarts berries"].each do |ingredient|
      assert_empty IngredientUnits.violations(ingredient), ingredient
    end
  end

  def test_rejects_aliases_capitalization_and_periods
    ["1 teaspoon salt", "2 Tablespoons oil", "1 Tbsp sugar", "1 tsp. salt",
     "2 lbs beef", "8 oz. cheese", "52 grams oil", "2 L stock", "1 c flour",
     "2 T yeast", "1 t salt", "1 tbl oil", "1 (28-oz.) can tomatoes"].each do |ingredient|
      refute_empty IngredientUnits.violations(ingredient), ingredient
    end
  end

  def test_checks_secondary_amounts_and_package_sizes
    ["¼ cup butter (4 Tbsp)", "2 cups plus 2 tablespoons flour",
     "2 cans (28 ounces) beans", "Three 8 oz. cans tomato sauce"].each do |ingredient|
      refute_empty IngredientUnits.violations(ingredient), ingredient
    end
  end

  def test_requires_spacing_between_quantity_and_unit
    ["250g flour", "19oz beans", "4lb. chicken", "½tsp salt"].each do |ingredient|
      assert IngredientUnits.violations(ingredient).any? { |error| error.include?("space") }, ingredient
    end
  end

  def test_allows_counts_unmeasured_ingredients_and_preparation_dimensions
    ["2 eggs", "Salt to taste", "1 pinch salt", "1 stick butter", "2 cloves garlic",
     "1-inch pieces", "1 batch [dough](/recipes/oz/)", "Sesame seeds, for serving"].each do |ingredient|
      assert_empty IngredientUnits.violations(ingredient), ingredient
    end
  end
end
