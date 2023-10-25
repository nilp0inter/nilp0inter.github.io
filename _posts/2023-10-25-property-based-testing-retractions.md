---
layout: default
title: "Property Based Testing - Retractions and Sections"
---
<!--
I am writing this article for my blog about property based testing using
hypothesis. It is not a general introduction to property based testing, but
a particular pattern that I have found useful in my work.  I am explaining it
from a mathematical perspective first and then showing how it shows all over
the place in software.  I am using python and hypothesis for the examples.

The general structure of the article is the following:

1.  Introduction to property based testing
2.  Introduction to retractions section pairs from category theory
3.  Examples of retractions and sections in software
4.  Examples of property based tests using hypothesis
5.  Conclusion

-->

# Property Based Testing - Retractions and Sections

## Introduction

Property based testing is a technique for testing software that is based on
generating random inputs to a function and checking that the output satisfies
some property.  The idea is that if the property is true for a large number of
random inputs, then it is likely to be true for all inputs.  This is a
powerful technique that can be used to find bugs in software that are hard to
find using other techniques.

In this article I will explain a very common software construction that
can be very nicely tested using property based testing.  This construction
is called a retraction section pair.

## Retractions and Sections

First let me explain what a retraction section pair is.  A retraction
section pair is a pair of functions $i\colon A\to B$ and $r\colon B\to A$
such that $r\circ i = id_A$.  Here $id_A$ is the identity function on $A$.

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
