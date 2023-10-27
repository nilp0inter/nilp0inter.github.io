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

The target for this article is people that are already familiar with
python and testing, but that are not familiar with property based testing
or category theory.  So after every concept I will explain it in plain
english and then show how it is used in software.

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
section pair is a pair of functions:

* A section function: $i\colon A\to B$
* A retraction function: $r\colon B\to A$

Such that when composed in a particular order they give the identity function
on $A$.  That is $r\circ i = id_A$.  This is illustrated in the following
diagram:

$$
  id_A
    \;\colon\; 
  A \overset{section}{\underset{i}{\to}} B \overset{retraction}{\underset{r}{\to}} A
  \,.
$$

In plain english this means that the section function $i$ knows how to
transform each and every element of $A$ into an element of $B$, in such a way
that the retraction function $r$ knows how to transform all elements of $B$
back into the original elements of $A$.

This abstract definition may seem uninteresting, but it is actually a very
common pattern in software, and it is very useful when you consider practical
instances of what $A$ and $B$ can be.

For the rest of the article I am going to change the name of the sets to better
reflect the kind of things that they can be.  I am going to call $A$ the
*source* set and $B$ the *target* set.  I am also going to call the section
function $i$ the *injector* and the retraction function $r$ the *extractor*.

The revised diagram looks like this:

$$
  id_{source}
    \;\colon\; 
  source \overset{injector}{\to} target \overset{extractor}{\to} source
  \,.
$$

## Examples of Retractions and Sections in Software

Enough with the abstract definitions, let's see some examples of retractions
and sections in software.

<!--
TODO: Examples to cover
- serializers and deserializers (example: pickle, then name baseN family, json, yaml, etc)
- compressors and decompressors
- encryption and decryption
- encoders and decoders

NOTE: Show them in a table at the end

-->

### Serializers and Deserializers

A very common example of a retraction section pair is a serializer and a
deserializer.  A serializer is a function that takes a piece of data in some
particular language and converts it into a string or a binary blob.  A
deserializer is a function that takes a string or a binary blob and converts
it back into the original data.

For example, the python `pickle` module has two functions `dumps` and `loads`
that are a retraction section pair.  The `dumps` function takes any python
object and converts it into a binary blob.  The `loads` function takes that
binary blob and converts it back into the original python object.

```python
import pickle

def test_pickle():
    obj = [1, 2, 3]
    assert pickle.loads(pickle.dumps(obj)) == obj
```


## Summary

| Section | Retraction | Set $A$ | Set $B$ |
|---------|------------|-------|-------|
| b64encode | b64decode | binary data | base64 encoded string |
| b32encode | b32decode | binary data | base32 encoded string |
| b16encode | b16decode | binary data | base16 encoded string |
| json.dumps | json.loads | python object | json string |
| pickle.dumps | pickle.loads | python object | pickled string |
| zlib.compress | zlib.decompress | binary data | compressed binary data |
| gzip.compress | gzip.decompress | binary data | compressed binary data |
| bz2.compress | bz2.decompress | binary data | compressed binary data |
| lzma.compress | lzma.decompress | binary data | compressed binary data |



