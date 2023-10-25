---
layout: default
title: "nilp0inter's blog"
---
# nilp0inter's blog

Here I post some of my thoughts and ideas about programming, computer science and other stuff.

## Posts list

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.date | date: "%Y-%m-%d" }} - {{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
