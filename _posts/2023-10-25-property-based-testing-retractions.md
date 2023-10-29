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

In plain English this means that the section function $i$ knows how to
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
deserializer is a function that takes a string or a binary blob and converts it
back into the original data.

For example, the python *pickle* module has two functions *dumps* and *loads*
that are a retraction section pair.  The *dumps* function takes any python
object and converts it into a binary blob.  The *loads* function takes that
binary blob and converts it back into the original python object.

```python
import pickle

def test_pickle():
    obj = [1, 2, 3]
    assert pickle.loads(pickle.dumps(obj)) == obj
```

In this case the source set is the set of all python objects* and the target set
is the set of all binary blobs.  The injector function is *pickle.dumps* and
the extractor function is *pickle.loads*.

\* Actually the source set is the set of all python objects that can be
pickled, but for the sake of this example let's ignore that.

### Compressors and Decompressors

Another example of a retraction section pair is a compressor and a decompressor.

A compressor is a function that takes a piece of data and compresses it into a
*hopefully* smaller piece of data.  A decompressor is a function that takes
that compressed piece of data and decompresses it back into the original data.

For example, the python *zlib* module has two functions *compress* and
*decompress* that are a retraction section pair.  The *compress* function takes
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
is the set of all binary blobs.  The injector function is *zlib.compress* and
the extractor function is *zlib.decompress*.

\* Actually the compressed binary blob is not always smaller than the original,
if you don't believe me try compressing a file that is already compressed.


### Encoders and Decoders

Another example of a retraction section pair is an encoder and a decoder.

An encoder is a function that takes a piece of data and encodes it into a
string.  A decoder is a function that takes that string and decodes it back
into the original data.

For example, the python *base64* module has two functions *b64encode* and
*b64decode* that are a retraction section pair.  The *b64encode* function takes
any binary blob and encodes it into a string.  The *b64decode* function takes
that string and decodes it back into the original binary blob.

```python
import base64

def test_base64():
    data = b"hello world"
    assert base64.b64decode(base64.b64encode(data)) == data
```

In this case the source set is the set of all binary blobs and the target set
is the set of base64 encoded strings.  The injector function is
*base64.b64encode* and the extractor function is *base64.b64decode*.

## Summary

| injector function | extractor function | source set | target set |
|---------|------------|-------|-------|
| b64encode | b64decode | binary data | base64 encoded string |
| b32encode | b32decode | binary data | base32 encoded string |
| b16encode | b16decode | binary data | base16 encoded string |
| json.dumps | json.loads | python object | json string |
| pickle.dumps | pickle.loads | python object | pickled string |
| zlib.compress | zlib.decompress | binary data | zlib compressed binary data |
| gzip.compress | gzip.decompress | binary data | gzip compressed binary data |
| bz2.compress | bz2.decompress | binary data | bz2 compressed binary data |
| lzma.compress | lzma.decompress | binary data | lzma compressed binary data |
| codecs.decode* | codecs.encode | string | binary data |

\* for codecs that can represent the full set of Unicode code points


## Observations

Let's look at some common patterns that we can see in the examples above.

* Both the injector and the extractor are pure functions.  That is, they don't
  have any side effects.  They don't read or write to any files, they don't
  make any network requests, they don't mutate any global state, etc.
* The extractor function is the inverse of the injector function.  That is, if
  you apply the injector function to a value and then apply the extractor
  function to the result, you get back the original value.
* The injector function is a *total* function.  That is, it can be applied to
  any value in the source set.  There are no values in the source set that
  cannot be injected into the target set.
* Some of the injector functions share the same source set.  For example,
  *b64encode*, *b32encode*, and *b16encode* all take binary data and encode it
  into a string.  Similarly, *zlib.compress*, *gzip.compress*, *bz2.compress*,
  and *lzma.compress* all take binary data and compress it into a smaller
  binary blob.
* None of the extractor functions share the same target set.  For example,
  *b64decode*, *b32decode*, and *b16decode* all take a their respective encoded
  string and decode it back into binary data.  Furthermore, *zlib.decompress*,
  *gzip.decompress*, *bz2.decompress*, and *lzma.decompress* all take their
  respective compressed binary blob and decompress it back into binary data.

What is not part of the pattern is the following:

* The extractor function is not necessarily a total function.  That is, there
  may be values in the target set that cannot be extracted back into the
  source set.  For example, if you try to decode with *b64decode* a string that
  is not a valid base64 encoded string, you will get an error.
* The injector function is not necessarily the inverse of the extractor
  function.  That is, if you apply the extractor function to a value and then
  apply the injector function to the result, you may not get back the original
  value.  For example, if you try to encode with *b64encode* a string that is
  not a valid base64 encoded string, you will get a different string.


# Testing Retractions and Sections

Now that we have a better understanding of what retractions and sections are,
let's talk about how we can test them.  For this section we'll imagine that we
are writing a base64 encoder and decoder.

## Step 1: Write a Golden Test

A golden test is a test that compares the output of a function to a known
correct value.  For example, let's say we have a function *add* that adds two
numbers together.

```python
def add(a, b):
    return a + b
```

We can write a golden test for this function that compares the output of the
function to a known correct value.

```python
def test_add():
    assert add(1, 2) == 3
```

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
known correct value that we can use to test the inverse function.  If you recall
from the previous section, there are several injector functions that share the
same source set.  For example, *b64encode*, *b32encode*, and *b16encode* all
take binary data and encode it into a string.  If we have a golden test for
*b64encode* we are sure that the output of *b64encode* is a valid base64
encoded string and not anything else.

Note: If you want to have more than one golden test, you can make use of
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

## Step 2: Write a Test for the Retraction Section Pair

Up to this point our test strategy has been pretty straight forward.  We have
written a golden test for the injector function.  But now is where we get the
big hammer out.  We are going to test the retraction section pair.

```python
import base64

from hypothesis import given, strategies as st

@given(st.binary())
def test_b64encode_b64decode(data):
    assert base64.b64decode(base64.b64encode(data)) == data
```

The *@given* decorator tells the *hypothesis* library that we want to generate
random values from the *st.binary()* strategy and pass them to the test
function.  The *st.binary()* strategy generates random binary blobs of any
length.  The *hypothesis* library will generate a bunch of random binary blobs
and pass them to the test function.  The test function will then apply the
injector function to the random binary blob and then apply the extractor
function to the result.  If the extractor function is the inverse of the
injector function, then the result should be the same as the original random
binary blob.

## Extending the pattern

We can extend this pattern to other injector and extractor function pairs.  For
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

Note that in this example the source set is not binary data.  The source set is
any value that can be serialized into JSON.  Thankfully, the *hypothesis*
library allows us to define complex strategies that can generate random values
from any set we want.  You can read more about the *hypothesis* library and
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

## The benefits of testing retractions and sections

Testing the retraction section pair gives helps us trust that the extractor
function effectively reverses the injector function. 

We've put the injector function through its paces with a golden test, and we've
also tested the retraction section pair using a range of random values. 

If the injector function is a total function, rest assured, we've tested it
with every conceivable value from the source set. 

Similarly, if the extractor function is the reverse of the injector function,
we've made sure to test the retraction section pair with every possible value
from the source set. 

In essence, we've left no stone unturned. Both the injector function and the
retraction section pair have been tested with every possible value in the
source set. This thorough testing bolsters our confidence that the extractor
function is indeed the inverse of the injector function.


# A note on pureness

Note: Pure functions are those who: They don't read or write to any files, they
don't make any network requests, they don't mutate any global state, etc.

Even though it may seem like this pattern can be extended to non-pure functions
like a database query, in practice it is not a good idea.  Let's enumerate some
non-pure functions that follow this pattern.

  1. A database query that inserts a row into a table and returns the primary
     key and a query that selects a row from a table given the primary key.
  2. A function that writes a file to disk and a function that reads a file
     from disk.
  3. A function that sets an environment variable and a function that reads an
     environment variable.

The problem with testing these functions is that they are not referentialy
transparent.  In other words, the output of the function depends on the state
of the world.  Let's see what can go wrong if we try to test these functions.

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
