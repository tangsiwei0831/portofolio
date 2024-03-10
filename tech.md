---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home-tech
title: "Tech"
category: Tech
permalink: /tech
---
<h2> Bug </h2>
<ul style="list-style-type: circle"> 
    {% assign bugs = site.Bugs | sort:"order" %}
    {% for entry in bugs %}
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

<h2> Leetcode </h2>
<h2> Project </h2>
<ul style="list-style-type: circle"> 
    <li>
       <a href="https://github.com/tangsiwei0831/shopme" style="font-size: 1.25rem"> shopme </a>: Java Spring boot 3, MySQL, Thymeleaf template
    </li>
</ul>