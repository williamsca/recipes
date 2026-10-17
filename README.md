# recipes
Family recipes

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
