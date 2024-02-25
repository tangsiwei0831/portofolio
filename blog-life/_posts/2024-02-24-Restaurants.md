---
layout: post
title:  "Restaurants"
date:   2024-02-24 19:01:00
category: life
permalink: /life/restaurants
---
{% assign restaurants = site.Restaurants | sort:"order" %}
{% for entry in restaurants %}
  <h3>
    <a href="{{site.baseurl}}{{entry.url}}">
      {{ entry.title }}
    </a>
  {% if entry.highlights %}
    ({{ entry.highlights }})
  {% endif %}
  </h3>
{% endfor %}