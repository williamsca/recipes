require "minitest/autorun"
require "yaml"
require "kramdown"
require "uri"
require "set"

module RecipeContent
  ROOT = File.expand_path("..", __dir__)
  PATHS = Dir[File.join(ROOT, "_recipes", "**", "*.md")].sort.freeze
  REQUIRED_FIELDS = %w[title category ingredients instructions].freeze
  CATEGORIES = YAML.safe_load_file(File.join(ROOT, "_data/categories.yml")).map { |row| row.fetch("name") }.freeze
  CONFIG = YAML.safe_load_file(File.join(ROOT, "_config.yml"))
  BASEURL = CONFIG.fetch("baseurl", "").delete_suffix("/")

  def self.read(path)
    match = File.read(path).match(/\A---[^\S\n]*\n(.*?)^---[^\S\n]*$/m)
    raise ArgumentError, "#{path}: missing YAML front matter" unless match

    data = YAML.safe_load(match[1])
    raise ArgumentError, "#{path}: front matter must be a mapping" unless data.is_a?(Hash)

    [data, match.post_match]
  end

  def self.required_field_errors(data)
    REQUIRED_FIELDS.filter_map do |field|
      "#{field} must be a nonempty string" unless data[field].is_a?(String) && !data[field].strip.empty?
    end
  end

  def self.empty_bullets(markdown)
    # Include ordered lists and nested bullets. A bullet with content on the next
    # line is valid Markdown, so inspect parsed list items rather than bare lines.
    errors = []
    lines = markdown.lines
    walk(Kramdown::Document.new(markdown).root) do |node|
      next unless node.type == :li

      location = node.options[:location]
      marker = lines.fetch(location - 1, "").chomp.match(/\A( *)([-*+]|\d+[.)])[ \t]*\z/)
      following = lines.drop(location).find { |line| !line.strip.empty? }
      continuation = marker && following && following[/\A */].length >= marker[1].length + marker[2].length + 1
      # Kramdown can attach a following heading to a bare bullet. Require an
      # indented continuation when the marker's own line has no content.
      errors << location if !content?(node) || (marker && !continuation)
    end
    errors
  end

  def self.content?(node)
    return !node.value.to_s.strip.empty? if %i[text codespan codeblock].include?(node.type)
    return true if %i[img entity math].include?(node.type)
    return true if node.type == :html_element && node.value == "img"

    node.children.any? { |child| content?(child) }
  end

  def self.walk(node, &block)
    yield node
    node.children.each { |child| walk(child, &block) }
  end

  def self.links(markdown)
    document = Kramdown::Document.new(markdown)
    links = []
    walk(document.root) do |node|
      %w[href src].each do |attribute|
        links << [node.attr[attribute], node.options[:location]] if node.attr[attribute]
      end
    end
    # Undefined reference links are left as plain text by the Markdown parser.
    errors = document.warnings.select { |warning| warning.include?("link ID") }
    [links, errors]
  end

  def self.instructions?(text)
    return false unless text.is_a?(String)

    root = Kramdown::Document.new(text).root
    root.children.reject { |node| node.type == :header }.any? { |node| content?(node) }
  end

  def self.recipe_url(path)
    relative = path.delete_prefix(File.join(ROOT, "_recipes") + "/").delete_suffix(".md")
    pattern = CONFIG.fetch("collections").fetch("recipes").fetch("permalink")
    BASEURL + pattern.gsub(":collection", "recipes").gsub(":path", relative).gsub(":name", File.basename(relative))
  end

  # Build an index from source files, never _site (which may be stale or absent).
  def self.local_targets
    targets = Set.new
    PATHS.each { |path| targets << recipe_url(path) }
    Dir[File.join(ROOT, "**", "*")].each do |path|
      next unless File.file?(path)
      relative = path.delete_prefix(ROOT + "/")
      next if relative.split("/").any? { |part| part.start_with?("_", ".") } || relative.start_with?("test/", "vendor/")

      if %w[.md .html].include?(File.extname(path)) && File.read(path).start_with?("---\n")
        data, = read(path)
        destination = data["permalink"] || relative.sub(/\.md\z/, ".html")
        targets << BASEURL + "/" + destination.delete_prefix("/")
        targets << BASEURL + "/" + destination.delete_prefix("/").delete_suffix("index.html") if destination.end_with?("index.html")
        targets << BASEURL + "/" + destination.delete_prefix("/").delete_suffix(".html") if destination.end_with?(".html")
      else
        targets << BASEURL + "/" + relative
      end
    end
    targets
  end

  def self.broken_link?(destination, origin, targets)
    return false if destination.start_with?("#")

    uri = URI.parse(destination)
    # External URLs (including protocol-relative URLs) are not checked offline.
    return false if uri.scheme || uri.host

    resolved = URI.join("https://recipe-tests.invalid" + origin, destination)
    path = URI::DEFAULT_PARSER.unescape(resolved.path)
    !targets.include?(path)
  rescue URI::InvalidURIError
    true
  end
end

class RecipeContentTest < Minitest::Test
  TARGETS = RecipeContent.local_targets.freeze

  def test_recipes_are_discovered
    refute_empty RecipeContent::PATHS
  end

  RecipeContent::PATHS.each do |path|
    name = File.basename(path, ".md")

    define_method("test_required_fields_in_#{name}") do
      data, = RecipeContent.read(path)
      errors = RecipeContent.required_field_errors(data)
      assert errors.empty?, "#{path}: #{errors.join('; ')}"
    end

    define_method("test_category_in_#{name}") do
      data, = RecipeContent.read(path)
      assert_includes RecipeContent::CATEGORIES, data["category"], "#{path}: invalid category; choose from #{RecipeContent::CATEGORIES.join(', ')}"
    end

    define_method("test_no_empty_bullets_in_#{name}") do
      data, body = RecipeContent.read(path)
      sections = data.select { |_, value| value.is_a?(String) }.merge("body" => body)
      errors = sections.flat_map do |field, text|
        RecipeContent.empty_bullets(text).map { |line| "#{field} line #{line}: empty list item" }
      end
      assert errors.empty?, "#{path}: #{errors.join('; ')}"
    end

    define_method("test_instructions_in_#{name}") do
      data, = RecipeContent.read(path)
      # Group headings and empty list markers alone are not preparation steps.
      assert RecipeContent.instructions?(data["instructions"]), "#{path}: missing instructions or no preparation text"
    end

    define_method("test_local_links_in_#{name}") do
      data, body = RecipeContent.read(path)
      sections = data.select { |_, value| value.is_a?(String) }.merge("body" => body)
      errors = sections.flat_map do |field, text|
        links, warnings = RecipeContent.links(text)
        warnings.map { |warning| "#{field}: #{warning}" } + links.filter_map do |destination, line|
          "#{field} line #{line}: broken local link #{destination.inspect}" if RecipeContent.broken_link?(destination, RecipeContent.recipe_url(path), TARGETS)
        end
      end
      assert errors.empty?, "#{path}: #{errors.join('; ')}"
    end
  end
end

class RecipeContentCheckerTest < Minitest::Test
  def test_requires_each_core_field_and_rejects_blank_or_wrong_types
    valid = { "title" => "Toast", "category" => "Breakfast", "ingredients" => "- Bread", "instructions" => "1. Toast bread." }
    assert_empty RecipeContent.required_field_errors(valid)
    valid.each_key do |field|
      [nil, "", " \n", [], 42].each do |value|
        refute_empty RecipeContent.required_field_errors(valid.merge(field => value)), "#{field}: #{value.inspect}"
      end
      refute_empty RecipeContent.required_field_errors(valid.reject { |key, _| key == field })
    end
  end

  def test_detects_empty_ordered_unordered_and_nested_bullets
    ["- flour\n- \n", "* \n", "+ \n", "1. \n", "- flour\n  - \n", "- \n### Next group\n"].each do |text|
      refute_empty RecipeContent.empty_bullets(text), text
    end
    ["- Salt\n", "-\n  Salt\n", "1. Mix.\n   - Stir.\n", "```\n-\n```\n", "---\n"].each do |text|
      assert_empty RecipeContent.empty_bullets(text), text
    end
  end

  def test_instructions_need_preparation_text
    [nil, [], "", " \n", "### Preparation\n", "1. \n"].each do |text|
      refute RecipeContent.instructions?(text), text.inspect
    end
    ["1. Mix ingredients.\n", "Stir and serve.", "### Dough\n1. Knead.\n"].each do |text|
      assert RecipeContent.instructions?(text), text
    end
  end

  def test_extracts_markdown_reference_image_and_html_links
    markdown = "[dough](../dough/ \"Recipe\") ![photo](/photo.jpg) [bread][ref] <a href='/toast/'>Toast</a>\n\n[ref]: /bread/\n"
    links, warnings = RecipeContent.links(markdown)
    assert_empty warnings
    assert_equal %w[../dough/ /photo.jpg /bread/ /toast/], links.map(&:first)
    _, errors = RecipeContent.links("[missing][unknown]")
    refute_empty errors
  end

  def test_resolves_links_relative_to_recipe_url_and_ignores_query_and_fragment
    targets = Set["/recipes/recipes/dough/", "/recipes/assets/flour.jpg"]
    origin = "/recipes/recipes/danish/"
    %w[../dough/ /recipes/recipes/dough/?print=1#mix /recipes/assets/flour.jpg #mix https://example.com //example.com mailto:a@example.com].each do |link|
      refute RecipeContent.broken_link?(link, origin, targets), link
    end
    %w[../missing/ /recipes/assets/missing.jpg /recipes/recipes/dough%20missing/].each do |link|
      assert RecipeContent.broken_link?(link, origin, targets), link
    end
  end
end
