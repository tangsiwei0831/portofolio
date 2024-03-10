---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home-life
title: "Life"
category: life
permalink: /life
---
<h2> Restaurant </h2>
<ul style="list-style-type: circle">
  {% assign restaurants = site.Restaurants | sort:"order" %}
  {% for entry in restaurants %}
    <li>
      <h3>
        <a href="{{site.baseurl}}{{entry.url}}">
          {{ entry.title }}
        </a>
      </h3>
    {% if entry.highlights %}
      ({{ entry.highlights }})
    {% endif %}
    </li>
  {% endfor %}
</ul>

<h2> Food </h2>

<h2> Movies </h2>
<ul style="list-style-type: circle">
  {% assign movies = site.Movies | sort:"order" %}
  {% for entry in movies %}
    <li>
        <h3>
          <a href="{{site.baseurl}}{{entry.url}}">
            {{ entry.title }}
          </a>
        </h3>
      {% if entry.highlights %}
        ({{ entry.highlights }})
      {% endif %}
    </li>
  {% endfor %}
</ul>

<h2> Poetry </h2>