---
layout: default
title: "Property Based Testing - Retractions and Sections"
---
<!--
I am writing this article for my blog about property based testing using
hypothesis. It is not a general introduction to property based testing, but
a particular pattern that I have found useful in my work. I am explaining it
from a mathematical perspective first and then showing how it shows all over
the place in software. I am using python and hypothesis for the examples.

The general structure of the article is the following:

1. Introduction to property based testing
2. Introduction to retractions section pairs from category theory
3. Examples of retractions and sections in software
4. Examples of property based tests using hypothesis
5. Conclusion

The target for this article is people that are already familiar with
python and testing, but that are not familiar with property based testing
or category theory. So after every concept I will explain it in plain
english and then show how it is used in software.

-->

# Property Based Testing - Retractions and Sections

## Introduction

Property based testing is a technique for testing software that is based on
generating random inputs to a function and checking that the output satisfies
some property. The idea is that if the property is true for a large number of
random inputs, then it is **likely to be true[^1]** for all inputs. This is a
powerful technique that can be used to find bugs in software that are hard to
find using other techniques.

TODO: find a real use case.

In this article I will explain a very common software construction that
can be very nicely tested using property based testing. This construction
is called a retraction section pair in mathematics.


Instead of jumping straight into the examples, let me first give you the
abstract definition of a retraction section pair. This will help you
understand the examples better, and it will also help you see the pattern in
other places.

## Retractions and Sections

A retraction section pair is a pair of functions:

* A section function: $i\colon A\to B$
* A retraction function: $r\colon B\to A$

Such that when composed in a particular order they give the identity function
on $A$. That is $r\circ i = id_A$. This is illustrated in the following
diagram:

$$
  id_A
    \;\colon\; 
  A \overset{section}{\underset{i}{\to}} B \overset{retraction}{\underset{r}{\to}} A
  \,.
$$

In plain English this means that the section function $i$ knows how to
transform each and every element of $A$ into an element of $B$[^2], in such a way
that the retraction function $r$ knows how to transform all elements of $B$
back into the original elements of $A$.

This abstract definition may seem uninteresting at first glance, but it is
actually a very common pattern in software, and a very useful one when you
consider practical instances of what $A$ and $B$ can be.

For the rest of the article I am going to change the name of the sets to better
reflect the kind of things that they can be. I am going to call $A$ the
*source set* and $B$ the *target set*.

The revised diagram looks like this:

$$
  id_{source}
    \;\colon\; 
  source set \overset{section}{\to} target set \overset{retraction}{\to} source set
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

A very common example of a retraction section pair is a *serializer* and a
*deserializer*. A *serializer* is a function that takes a piece of data in
some particular language and converts it into a string or a binary blob. The
*deserializer* is a function that takes **that** string or a binary blob and
converts it back into the original data.

For example, the python *pickle* module has two functions *dumps* and *loads*
that form a retraction section pair. The *dumps* function takes any python
object and converts it into a binary blob. The *loads* function takes that
binary blob and converts it back into the original python object.

```python
import pickle

def test_pickle():
    obj = [1, 2, 3]
    assert pickle.loads(pickle.dumps(obj)) == obj
```

In this case the *source set* is the set of all python objects[^3] and the
target set is the set of all binary blobs. The section function is
*pickle.dumps* and the retraction function is *pickle.loads*.

### Compressors and Decompressors

Another example of a retraction section pair is a compressor and a decompressor.

A compressor is a function that takes a piece of data and compresses it into a
hopefully[^4] smaller piece of data. A decompressor is a function that takes
that compressed piece of data and decompresses it back into the original data.

For example, the python *zlib* module has two functions *compress* and
*decompress* that are a retraction section pair. The *compress* function takes
any binary blob and compresses it into a smaller* binary blob. The *decompress*
function takes that compressed binary blob and decompresses it back into the
original binary blob.

```python
import zlib

def test_zlib():
    data = b"hello world"
    assert zlib.decompress(zlib.compress(data)) == data
```

In this case the source set is the set of all binary blobs and the target set
is the set of all binary blobs. The section function is *zlib.compress* and
the retraction function is *zlib.decompress*.


### Encoders and Decoders

Our final example of a retraction section pair is an encoder and a decoder.

An encoder is a function that takes a piece of data and encodes it into a
format that is suitable for transmission over a network or storage on disk,
usually a string. A decoder is a function that takes that string and decodes it
back into the original data.

For example, the python *base64* module has two functions *b64encode* and
*b64decode* that are a retraction section pair. The *b64encode* function takes
any binary blob and encodes it into a string. The *b64decode* function takes
that string and decodes it back into the original binary blob.

```python
import base64

def test_base64():
    data = b"hello world"
    assert base64.b64decode(base64.b64encode(data)) == data
```

In this case the source set is the set of all binary blobs and the target set
is the set of base64 encoded strings. The section function is
*base64.b64encode* and the retraction function is *base64.b64decode*.

## Summary

| section function | retraction function | source set | target set |
|---------|------------|-------|-------|
| base64.b{16,32,64,...}encode | base64.b{16,32,64,...}decode | binary blob | base{16,32,64,...} encoded string |
| json.dumps | json.loads | python object that can be serialized to json | json string |
| pickle.dumps | pickle.loads | python object that can be serialized to pickle | pickle binary blob |
| {zlib,gzip,bz2,lzma}.compress | {zlib,gzip,bz2,lzma}.decompress | binary blob | {zlib,gzip,bz2,lzma} compressed binary blob |
| codecs.decode[^5] | codecs.encode | string | string encoded in a different encoding |


## Observations

Let's look at some common patterns that we can see in the examples above.

* Both the section and the retraction are pure functions. That is, they don't
  have any side effects. They don't read or write to any files, they don't
  make any network requests, they don't mutate any global state, etc.
* The retraction function is the inverse of the section function. That is, if
  you apply the section function to a value and then apply the retraction
  function to the result, you get back the original value.
* The section function is a *total* function. That is, it can be applied to
  any value in the source set. There are no values in the source set that
  cannot be injected into the target set.
* Some of the section functions share the same source set. For example,
  *b64encode*, *b32encode*, and *b16encode* all take binary data and encode it
  into a string. Similarly, *zlib.compress*, *gzip.compress*, *bz2.compress*,
  and *lzma.compress* all take binary data and compress it into a smaller
  binary blob.
* None of the retraction functions share the same target set. For example,
  *b64decode*, *b32decode*, and *b16decode* all take their respective encoded
  byte string and decode it back into binary data. Furthermore,
  *zlib.decompress*, *gzip.decompress*, *bz2.decompress*, and *lzma.decompress*
  all take their respective compressed binary blob and decompress it back into
  binary data.

What is not part of the pattern is the following:

* The retraction function is not necessarily a total function. At least for the
  type annotated as the target set in the source code. For example, the
  *b64decode* function signature may tell you that it takes a byte string and
  returns a byte string. However, if you give it you give it a byte string
  that is not a valid base64 encoded string, you will get an error.
* The section function is not necessarily the inverse of the retraction
  function. If this were the case, instead of having a section retraction
  pair, we would have an isomorphism[^6].

# Testing Retractions and Sections

Now that we have a better understanding of what retractions and sections are,
let's talk about how we can test them using property based testing. For this
section we'll imagine that we are writing a base64 encoder and decoder.

## Step 1: Write a Golden Test

A golden test is a test that compares the output of a function to a known
correct value.

In the case of base64 encoding, we can write a golden test that compares the
output of *b64encode* to a known correct value.

```python
import base64

def test_b64encode():
    expected = b"aGVsbG8gd29ybGQ="
    actual = base64.b64encode(b"hello world")
    assert actual == expected
```

The reason why a golden test is a good place to start is because it gives us a
known correct so that we are sure we are implementing the right thing. If you
recall from the previous section, there are several section functions that
share the same source set. For example, *b64encode*, *b32encode*, and
*b16encode* all take binary data and encode it into a string. If we have a
golden test for *b64encode* we are sure that the output of *b64encode* is a
valid base64 encoded string and not anything else.

It is maybe a good idea to test more than one value. For that we can use
pytest's parametrize feature.

```python
import base64

import pytest

@pytest.mark.parametrize("data,expected", [
    (b"hello world", b"aGVsbG8gd29ybGQ="),
    (b"foo bar", b"Zm9vIGJhcg=="),
])
def test_b64encode(data, expected):
    actual = base64.b64encode(data)
    assert actual == expected
```

## Step 2: Write a Hypothesis Test for the Section Retraction Pair

Up to this point our test strategy has been pretty straight forward. We have
written a golden test for the section function. And now is where we get the
big hammer out. We are going to test the retraction section pair.

```python
import base64

from hypothesis import given, strategies as st

@given(st.binary())
def test_b64encode_b64decode(data):
    assert base64.b64decode(base64.b64encode(data)) == data
```

The decorator *@given* is a signal to the *hypothesis* library that we want to
generate random values using the *st.binary()* strategy. These values are then
fed into the test function. The *st.binary()* strategy is specifically designed
to create random binary blobs of different lengths. In simpler terms, it's like
saying that the source set is made up of all possible binary blobs.

Next, the *hypothesis* library will churn out a series of these random binary
blobs and inject them into the test function. This function will first apply
the section function to the random binary blob, and then the retraction
function to the output that results.

Looking at it from a mathematical perspective, this test is basically asserting
a theorem. The theorem in question suggests that the retraction-section pair
operates as the identity function.

## Extending the pattern

We can extend this pattern to other section and retraction function pairs. For
example, we can test the retraction section pair for *gzip.compress* and
*gzip.decompress*.

```python
import gzip

from hypothesis import given, strategies as st

def test_gzip_compress():
    expected = b"\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x03K\xcb\xcf\x07\x00\x82"
    actual = gzip.compress(b"hello world")
    assert actual == expected

@given(st.binary())
def test_gzip_compress_gzip_decompress(data):
    assert gzip.decompress(gzip.compress(data)) == data
```

Or we can test the retraction section pair for *json.dumps* and *json.loads*.

```python
import json

from hypothesis import given, strategies as st

json_serializable_strategy = st.recursive(
    st.none() | st.booleans() | st.floats() | st.text(),
    lambda children: st.lists(children) | st.dictionaries(st.text(), children),
)

def test_json_dumps():
    expected = '{"hello": "world"}'
    actual = json.dumps({"hello": "world"})
    assert actual == expected

@given(json_serializable_strategy)
def test_json_dumps_json_loads(data):
    assert json.loads(json.dumps(data)) == data
```

Note that in this example the source set is not binary data. The source set is
any value that can be serialized into JSON. Thankfully, the *hypothesis*
library allows us to define complex strategies that can generate random values
from any set we want. You can read more about the *hypothesis* library and
strategies in the [hypothesis documentation](https://hypothesis.readthedocs.io/en/latest/data.html).

We also can test the retraction section pair for *codecs.encode* and
*codecs.decode* for the *utf-8* encoding.

```python
import codecs

from hypothesis import given, strategies as st

def test_codecs_encode():
    expected = b"hello world"
    actual = codecs.encode("hello world", "utf-8")
    assert actual == expected

@given(st.text())
def test_codecs_encode_codecs_decode(data):
    assert codecs.decode(codecs.encode(data, "utf-8"), "utf-8") == data
```

# Composing retractions and sections pairs

Retraction section pairs compose very nicely. If we have two retraction
section pairs of the following form $A \overset{section}{\underset{i}{\to}} B \overset{retraction}{\underset{r}{\to}} A \,$ and $B \overset{section}{\underset{j}{\to}} C \overset{retraction}{\underset{s}{\to}} B \,$

Then we can compose the two retraction section pairs to get a new retraction:

$$
  A \overset{section}{\underset{i \circ j}{\to}} C \overset{retraction}{\underset{r \circ s}{\to}} A
  \,.
$$

In other words, if we have two retraction section pairs with compatible types,
then we can compose them to get a new retraction section pair. Let's see an
example of this in action.

The first section is the *json.dumps* which accepts any value that can be
serialized into JSON and returns a string. And the second section is the
*codecs.encode* (using the *utf-8* encoding) which accepts a string and returns
a byte string.

The retractions are the respective inverses of the sections.

```python
import codecs
import json

def json_utf8_dumps(data):
    return codecs.encode(json.dumps(data), "utf-8")

def json_utf8_loads(data):
    return json.loads(codecs.decode(data, "utf-8"))
```

We can go even further and compose this new retraction section pair with the
*gzip.compress* and *gzip.decompress* retraction section pair.

```python
import gzip

def json_utf8_gzip_compress(data):
    return gzip.compress(json_utf8_dumps(data))

def json_utf8_gzip_decompress(data):
    return json_utf8_loads(gzip.decompress(data))
```

And test it all at once.

```python
from hypothesis import given, strategies as st

json_serializable_strategy = st.recursive(
    st.none() | st.booleans() | st.floats() | st.text(),
    lambda children: st.lists(children) | st.dictionaries(st.text(), children),
)

@given(json_serializable_strategy)
def test_json_utf8_gzip_compress_json_utf8_gzip_decompress(data):
    assert json_utf8_gzip_decompress(json_utf8_gzip_compress(data)) == data
```

# The Benefits of Testing Retraction Section Pairs

The advantage of testing retraction section pairs in this manner is that it
boosts our confidence in the code's accuracy over time, without the need for
extra tests. This is due to the fact that the 'hypothesis' library generates
new random values for each test run, which are then used to test the retraction
section pair.

However, this isn't the case with a conventional unit test. A traditional unit
test only tests the code with the values supplied by the test author. As a
result, our confidence in the code's accuracy remains unchanged over time.

# A note on pure functions[^7]

Even though it may seem like this pattern can be extended to non-pure
functions, in practice it is not a good idea. Let's enumerate some non-pure
functions that follow this pattern.

  1. A database query that inserts a row into a table and returns the primary
     key and a query that selects a row from a table given the primary key.
  2. A function that writes a file to disk and a function that reads a file
     from disk.
  3. A function that sets an environment variable and a function that reads an
     environment variable.

The problem with testing these functions is that they are not referentialy
transparent. In other words, the output of the function depends on the state
of the world. Let's see what can go wrong if we try to test these functions.

1. A database query that inserts a row into a table and returns the primary key
   and a query that selects a row from a table given the primary key.
  
  * What would happen if the database is down?
  * What would happen if we run out of primary keys?
  * What if the database contains a unique constraint on one of the
    columns?

2. A function that writes a file to disk and a function that reads a file from
   disk.
  
  * What if the file is not writable?
  * What if the file is not readable?
  * What if the filesystem is full?

3. A function that sets an environment variable and a function that reads an
    environment variable.
  
  * What happen if in between the time we set the environment variable and
    the time we read the environment variable, another part of the program
    sets the environment variable to something else?

In all of these cases, the output of the function depends on the state of the
world.

[^1]: TODO: Explain this is a stocastic process and that we can't test every
    possible value in the source set.

[^2]: Please be aware that $A$ and $B$ can represent any sets. Specifically, if
    $A$ is an infinitely large set, then $B$ has the potential to be a subset
    of $A$.

[^3]: Actually the *source set* is the set of all python objects that can be
    pickled, see [here](https://docs.python.org/3/library/pickle.html#what-can-be-pickled-and-unpickled) for more details.

[^4]: Of course the compressed binary blob is not always smaller than the
    original, you've probably seen this before when you've tried to compress a
    file that is already compressed.

[^5]: for codecs that can represent the full set of Unicode code points

[^6]: An isomorphism is a pair of functions that are inverses of each other. An
    example of isomorphism in python are the functions *list()* and *tuple()*.
    You can always convert a list to a tuple and back again without gaining or
    losing any information.

[^7]: A pure function is a function that given the same input always returns
    the same output. In other words, a pure function is referentialy
    transparent.
