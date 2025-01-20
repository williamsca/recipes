---
layout: default
title: Home
---

<!-- Category Cards -->
<div class="category-grid">
  {% assign categories = site.recipes | map: "category" | uniq %}
  {% for category in categories %}
    {% assign category_slug = category | downcase | replace: " ", "-" %}
    <div class="category-card">
      {% if site.data.category_images[category] %}
        <img src="{{ site.data.category_images[category] | relative_url }}" alt="{{ category }}">
      {% endif %}
      <h2>{{ category }}</h2>
      <a href="{{ '/categories/' | append: category_slug | append: '.html' | relative_url }}" class="category-link">
        View {{ category }} Recipes
      </a>
    </div>
  {% endfor %}
</div>