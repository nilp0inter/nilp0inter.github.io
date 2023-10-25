---
layout: default
title: "Property Based Testing - Retractions"
---

## Definition

An object $A$ in a category is called a **retract** of an object $B$ if there are morphisms $i\colon A\to B$ and $r \colon B\to A$ such that $r \circ i = id_A$. In this case $r$ is called a **retraction** of $B$ onto $A$.

$$
  id 
    \;\colon\; 
  A \overset{section}{\underset{i}{\to}} B \overset{retraction}{\underset{r}{\to}} A
  \,.
$$

Here $i$ may also be called a _section_ of $r$. (In particular if $r$ is thought of as exhibiting a bundle; the terminology originates from topology.)

```python
@given(st.bytes())
def test_retraction(b):
    assert unzip(zip(b)) == b

```
