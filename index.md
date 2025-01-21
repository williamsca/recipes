---
layout: default
title: Our Family Recipes
---

<div class="category-grid">
  <a href="{{ '/categories/breakfast' | relative_url }}" class="category-card breakfast">
    <div class="category-icon">
      ☕
    </div>
    <h2>Breakfast</h2>
    <div class="category-description">
      Start your day the Gergich way
    </div>
  </a>

  <a href="{{ '/categories/main' | relative_url }}" class="category-card main">
    <div class="category-icon">
      🍽️
    </div>
    <h2>Main Dishes</h2>
    <div class="category-description">
      Hearty meals for lunch and dinner
    </div>
  </a>

  <a href="{{ '/categories/fika' | relative_url }}" class="category-card fika">
    <div class="category-icon">
      🇸🇪
    </div>
    <h2>Fika</h2>
    <div class="category-description">
      You should try the Swedish fika 
    </div>
  </a>

  <a href="{{ '/categories/dessert' | relative_url }}" class="category-card dessert">
    <div class="category-icon">
      🧁
    </div>
    <h2>Desserts</h2>
    <div class="category-description">
      
    </div>
  </a>
</div>

<style>
.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
  padding: 2rem;
}

.category-card {
  display: block;
  background: white;
  border-radius: 1rem;
  padding: 2rem 1.5rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  text-decoration: none;
  color: inherit;
  text-align: center;
}

.category-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
}

.category-card:active {
  transform: translateY(-2px);
}

.category-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.category-card h2 {
  margin: 0 0 0.5rem 0;
  color: #333;
  font-size: 1.5rem;
}

.category-description {
  color: #666;
  font-size: 0.9rem;
  line-height: 1.4;
}

@media (max-width: 768px) {
  .category-grid {
    padding: 1rem;
    gap: 1rem;
  }
  
  .category-card {
    padding: 1.5rem 1rem;
  }
  
  .category-icon {
    font-size: 2.5rem;
  }
}
</style>