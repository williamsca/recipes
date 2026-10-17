# recipes
Family recipes

## Recipe tests

Run the complete suite with `bundle exec ruby test/run.rb` from the repository
root (run `bundle install` first if the site's Ruby dependencies are not installed).
No website build is needed. The content checks use Kramdown, the site's existing
Markdown parser, and read recipe source files directly.

The suite checks:

- Nonempty string fields: `title`, `category`, `ingredients`, and `instructions`.
  Timing, servings, source, and other metadata remain optional.
- Exact category names from `_data/categories.yml`.
- Empty unordered, numbered, and nested list items in recipe text, including
  ingredients, instructions, and notes. Indented continuation text is allowed.
- Instructions containing preparation text rather than only headings or empty lists.
- Local link and image destinations in recipe text, including reference links and
  HTML `href`/`src` attributes. Destinations are resolved against source recipes,
  pages, and assets using the configured base URL and recipe permalink; `_site`
  is never consulted. Query strings and fragments do not affect destination checks.
  Fragment anchors and external URL availability are not checked; tests run offline.
- Ingredient unit style, described below. Equivalent amounts are not compared.

Run only the new content checks with `bundle exec ruby test/recipe_content_test.rb`.

## Ingredient unit tests

Run `ruby test/ingredient_units_test.rb` from the repository root. The tests use
Ruby's bundled Minitest and YAML libraries; no Jekyll build or Bundler install is
needed. They read every `_recipes/**/*.md` file's `ingredients` front matter
directly, so layout and website changes do not affect them. Failures identify the
recipe, line within its ingredient field, and suggested spelling.

For phone screens, use `tsp` and `tbsp`: they keep ingredient lines short while
avoiding the easily confused `t`/`T` shorthand. Use this style consistently:

| Measurement | Ingredient spelling |
| --- | --- |
| Teaspoon / tablespoon | `tsp` / `tbsp` |
| Cup | `cup` / `cups` |
| Ounce / pound | `oz` / `lb` |
| Gram / kilogram | `g` / `kg` |
| Milliliter / liter | `ml` / `l` |
| Pint / quart / gallon | `pint(s)` / `quart(s)` / `gallon(s)` |

Use lowercase, no abbreviation periods, and a space after the quantity (`250 g`,
not `250g`). Hyphenated package sizes such as `1 (28-oz) can tomatoes` are allowed.
Checks include secondary measurements and package sizes within ingredient list
items, including grouped lists. They reject known alternative unit spellings;
they do not infer units from arbitrary ingredient words or check singular/plural
agreement. Counts (`2 eggs`, `1 stick butter`), unmeasured ingredients (`salt to
taste`), group headings, instructions, and notes are outside the unit rules.
Quantities and the choice of measurement system are preserved.

# TODO
- [ ] search result shows quantity of ingredient???
- [ ] add soups

# DONE
- [X] redesign: cookbook styling, spot illustrations (`icon:` in front matter, files in assets/icons), `### ` sub-headers for ingredient groups, merged list view
- [X] import recipes
- [X] more recipes: tiramisu, cinnamon rolls  
- [X] sortable table
- [X] formatting
- [X] import breakfasts
- [X] search
- [X] footer; write about
- [X] add protein to dinner category table
- [X] clean up category tables
  - [X] swap to "Effort" (Low, Medium, High) and "Duration" (Short, Medium, Long)
  - [X] fix mobile so table isn't wider than screen
- [X] menu / table swap?
