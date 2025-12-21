---
title: "Property Based Testing - Retractions and Sections"
date: 2023-10-25T12:00:00Z
slug: "property-based-testing-retractions"
categories: ["software"]
years: ["2023"]
draft: false
math: true
---


## Introduction

Property based testing is a technique for testing software that is based on
generating random inputs to a function and checking that the output satisfies
some property. The idea is that if the property is true for a large number of
random inputs, then it is *likely* to be true for all inputs. This is a
powerful technique that can be used to find bugs in software that are hard to
find using traditional testing techniques.

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
  {source\ set} \overset{section}{\to} {target\ set} \overset{retraction}{\to} {source\ set}
$$

## Examples of Retractions and Sections in Software

Enough with the abstract definitions, let's see some examples of retractions
and sections in software.

### Serializers and Deserializers

A very common example of a retraction section pair is a *serializer* and a
*deserializer*. A *serializer* is a function that takes a piece of data in some
particular programming language and converts it into a string or a binary blob.
The *deserializer* is a function that takes **that** string or a binary blob
and converts it back into the original data.

For example, the python *pickle* module has two functions *dumps* and *loads*
that form a retraction section pair. The *dumps* function takes any python
object[^3] and converts it into a python *bytes()* object. The *loads* function
takes that *bytes()* object and converts it back into the original python
object.

```python
>>> import pickle
>>> x=pickle.dumps([1, 2, 3])
>>> x
b'\x80\x04\x95\x0b\x00\x00\x00\x00\x00\x00\x00]\x94(K\x01K\x02K\x03e.'
>>> pickle.loads(x)
[1, 2, 3]
```

In this scenario, the *source set* refers to the entire collection of Python
objects. On the other hand, the *target set* is the collection of python
*bytes()* objects that can be correctly decoded into Python objects using
pickle. The section function is *pickle.dumps* and the retraction function is
*pickle.loads*.

### Compressors and Decompressors

Another example of a retraction section pair is a compressor and a decompressor.

A compressor is a function that takes a piece of data and compresses it into a
(hopefully[^4]) smaller piece of data. A decompressor is a function that takes
that compressed piece of data and decompresses it back into the original data.

For example, the python *zlib* module has two functions *compress* and
*decompress* that are a retraction section pair. The *compress* function takes
any python *bytes()* object and compresses it into a smaller *bytes()* object. The
*decompress* function takes that compressed *bytes()* object and decompresses it
back into the original *bytes()* object.

```python
>>> import zlib
>>> x=zlib.compress(b"hello world")
>>> x
b'x\x9c\xcbH\xcd\xc9\xc9W(\xcf/\xcaI\x01\x00\x1a\x0b\x04]'
>>> zlib.decompress(x)
b'hello world'
```

In this case the source set is the set of all *bytes()* objects and the target set
is the set of all zlib compressed *bytes()* objects. The section function is
*zlib.compress* and the retraction function is *zlib.decompress*.


### Encoders and Decoders

Our final example of a retraction section pair is an encoder and a decoder.

An encoder is a function that takes a piece of data and encodes it into a
format that is suitable for transmission over a network or storage on disk,
usually a string. A decoder is a function that takes that string and decodes it
back into the original data.

For example, the python *base64* module has two functions *b64encode* and
*b64decode* that are a retraction section pair. The *b64encode* function takes
any *bytes()* object and encodes it into an *bytes()* object only containing
the ASCII characters *A-Z*, *a-z*, *0-9*, *+*, */* and *=*. The *b64decode*
function takes that encoded *bytes()* object and decodes it back into the
original *bytes()* object.

```python
>>> import base64
>>> x=base64.b64encode(b"hello world")
>>> x
b'aGVsbG8gd29ybGQ='
>>> base64.b64decode(x)
b'hello world'
```

In this case the *source set* is the set of all *bytes()* objects and the *target set*
is the set of base64 encoded byte strings. The section function is
*base64.b64encode* and the retraction function is *base64.b64decode*.

## What counts as a Retraction Section Pair?

The examples above are just a few of the many retraction section pairs that
exist in software. In fact, there are so many of them that it is hard to
enumerate them all. Here is a list of some of them found in the Python standard
library:

| section function | retraction function | source set | target set |
|---------|------------|-------|-------|
| base64.b{16,32,64,...}encode | base64.b{16,32,64,...}decode | python *bytes()* object | base{16,32,64,...} encoded *bytes()* object (ASCII encoded string) |
| codecs.encode[^5] | codecs.decode | python string | byte representation of string in a different encoding |
| json.dumps | json.loads | python object that can be serialized to json | json encoded string |
| pickle.dumps | pickle.loads | python object that can be serialized to pickle | pickle encoded *bytes()* object |
| {zlib,gzip,bz2,lzma}.compress | {zlib,gzip,bz2,lzma}.decompress | python *bytes()* object | {zlib,gzip,bz2,lzma} compressed *bytes()* object |

Surprisingly, this list doesn't include a specific family of elements -
encryption and decryption block ciphers. These form a retraction section pair
for each algorithm and encryption key. The reason for this omission is simple:
there's no example of this in the Python standard library.

The following are **not** retraction section pairs:

1. Hash functions. Hash functions are not retraction section pairs because
   there is no way to get back the original value from the hash.
2. Lossy compression algorithms. Lossy compression algorithms are not
   retraction section pairs because there is no way to get back the original
   data from the compressed data. For example, the *jpeg* image format or *mp3*
   audio format.

## Picking out the patterns

Let's look at some common patterns that we can see in the examples above.

* Both the section and the retraction are pure functions. That is, they don't
  have any side effects. They don't read or write to any files, they don't
  make any network requests, they don't mutate any global state, etc.
* The retraction function is the inverse of the section function. If you apply
  the section function to a value and then apply the retraction function to the
  result, you get back the original value.
* The section function is a *total* function. It can be applied to any value in
  the source set. There are no values in the source set that cannot be injected
  into the target set.
* Some of the section functions share the same source set. 
* None of the retraction functions share the same target set. 
* Weirdly enough, even though the retraction functions don't share the same
  target set, [some of the elements of their sets can be the same](https://en.wikipedia.org/wiki/Polyglot_(computing)).


What is not part of the pattern is the following:

* The retraction function is not necessarily a total function. At least for the
  type annotated as the target set in the source code. For example, the
  *b64decode* function signature may tell you that it takes a byte string and
  returns a byte string. However, if you give it a byte string that is not a
  valid base64 encoded string, you will get an error.
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
to create random *bytes()* objects of different lengths. In simpler terms, it's
like saying that the source set is made up of all possible *bytes()* objects.

Next, the *hypothesis* library will churn out a series of these random binary
blobs and inject them into the test function. This function will first apply
the section function to the random *bytes()* object, and then the retraction
function to the output that results.

Looking at it from a mathematical perspective, this test is basically asserting
a theorem. The theorem in question suggests that the retraction-section pair
operates as the identity function.

## Let's Test Some More Retraction Section Pairs

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

## Testing Against a Golden Implementation

You may have noticed that the initial golden tests we created are somewhat
delicate. Not only do we need to craft these tests ourselves, but we also need
to ensure their accuracy. This isn't an issue for the *base64* module, given
its extensive testing. But what happens when we're developing our own module?
How can we be certain that our golden tests are accurate and testing the right
elements?

In some instances, we can compare our work to a golden implementation to verify
the correctness of our own. 

Imagine that we are implementing our own gzip compression library. Instead of
providing a few *golden tests*, we can test our implementation against the
*gzip* command line tool. This is a good example of a golden implementation
because it is well-tested and has been around for a long time.

```python
import gzip
import subprocess

from hypothesis import given, strategies as st

def external_gzip_compress(data):
    return subprocess.check_output(["gzip", "-c"], input=data)

def external_gzip_decompress(data):
    return subprocess.check_output(["gzip", "-cd"], input=data)

@given(st.binary())
def test_gzip_compress(data):
    assert external_gzip_decompress(gzip.compress(data)) == data

@given(st.binary())
def test_external_gzip_compress(data):
    assert gzip.decompress(external_gzip_compress(data)) == data

@given(st.binary())
def test_gzip_compress_gzip_decompress(data):
    assert gzip.decompress(gzip.compress(data)) == data

```


# Composing Retraction Section Pairs

Retraction section pairs compose very nicely. If we have two retraction
section pairs of the following form $A \overset{section}{\underset{i}{\to}} B \overset{retraction}{\underset{r}{\to}} A \,$ and $B \overset{section}{\underset{j}{\to}} C \overset{retraction}{\underset{s}{\to}} B \,$

Then we can compose the two retraction section pairs to get a new retraction
section pair.

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
   * What would be the outcome if the database is unavailable?
   * What would occur if we exhaust all available primary keys?
   * What if one of the columns in the database has a unique constraint?
   * What if someone else deletes the row between the time we insert it and
     select it?

2. A function that writes a file to disk and a function that reads a file from
   disk.
   * What happens if the file cannot be written to?
   * What if the file cannot be read?
   * What if there is no more space available on the filesystem?
   * What if the file is deleted between the time we write it and read it?

3. A function that sets an environment variable and a function that reads an
    environment variable.
   * What would happen if, in the time between setting the environment variable
     and reading it, another part of the program changes the value of the
     environment variable?

In all of these cases, the output of the function depends on the state of the
world.

# Conclusion

## The Benefits of Testing Retraction Section Pairs

The advantage of testing retraction section pairs in this manner is that it
boosts our confidence in the code's accuracy over time, without the need for
extra tests. This is due to the fact that the 'hypothesis' library generates
new random values for each test run, which are then used to test the retraction
section pair.

However, this isn't the case with a conventional unit test. A traditional unit
test only tests the code with the values supplied by the test author. As a
result, our confidence in the code's accuracy remains unchanged over time.

## Limitations of Testing Retraction Section Pairs

While this pattern holds significant power, it's not without its constraints.

The first constraint is its exclusive compatibility with pure functions. If you
attempt to apply this pattern to a non-pure function, tread carefully. You'll
need to be mindful of potential side effects and how they could impact the
test.

The second constraint is that our golden test only examines one or a handful of
values. This means that while we can be fairly certain that the retraction is
the inverse of the section, we can't be as confident that the section is our
intended function. However, this issue can be easily resolved by incorporating
more tests or, even better, by testing against a *golden implementation*!

---

[^1]: TODO: Explain this is a stocastic process and that we can't test every
    possible value in the source set.

[^2]: Please be aware that $A$ and $B$ can represent any sets. Specifically, if
    $A$ is an infinitely large set, then $B$ has the potential to be a subset
    of $A$.

[^3]: Actually the *source set* is the set of all python objects that can be
    pickled, see [here](https://docs.python.org/3/library/pickle.html#what-can-be-pickled-and-unpickled) for more details.

[^4]: Of course the compressed piece of data is not always smaller than the
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
