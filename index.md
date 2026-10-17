---
layout: default
title: Williams Recipes
---

<header class="title-page">
  <p class="title-page-kicker">favorite family recipes</p>
  <h1 class="title-page-title">a Cookbook<br>for Kaitlyn</h1>
  {% include herringbone.html %}
</header>

<section class="contents">
  <h2 class="ruled-heading">Contents</h2>
  <ul>
    {% for cat in site.data.categories %}
    {% assign count = site.recipes | where: "category", cat.name | size %}
    <li>
      <a href="{{ '/categories/' | append: cat.slug | relative_url }}">
        {% include recipe-icon.html name=cat.icon size=44 %}
        <span class="contents-name">{{ cat.name }}{% if cat.blurb %}<span class="contents-blurb">{{ cat.blurb }}</span>{% endif %}</span>
        <span class="contents-count">{{ count }}</span>
      </a>
    </li>
    {% endfor %}
  </ul>
</section>

<aside class="letters-card">
  <p>“Here are a few of the recipes that we’ve cooked together since we met…”</p>
  <a href="{{ '/about' | relative_url }}">read the letters, 2017–2025 ›</a>
</aside>
