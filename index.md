---
layout: default
title: The Recipes
---

{% for recipe in site.recipes %}
  <div class="recipe-card">
    <h2><a href="{{ recipe.url | relative_url }}">{{ recipe.title }}</a></h2>
    {% if recipe.description %}
      <p>{{ recipe.description }}</p>
    {% endif %}
    <div class="recipe-metadata">
      <span>Prep: {{ recipe.prep_time }}</span>
      <span>Cook: {{ recipe.cook_time }}</span>
    </div>
  </div>
{% endfor %}