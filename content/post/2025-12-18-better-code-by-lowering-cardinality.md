---
title: "Improve your Programs by Minimizing Cardinality"
date: 2025-12-18T12:00:00Z
slug: "better-code-by-lowering-cardinality"
categories: ["software"]
years: ["2025"]
draft: false
math: true
---


Software engineering is often described as a constant struggle against complexity. As our systems grow larger, the number of possible implementations states within the program explodes. This turns our code into a chaotic landscape where bugs can easily hide in the corners we forgot to check. To fight this, we usually rely on external tools like linters, detailed documentation, or exhaustive test suites.

However, there is a deeper principle we can use that is built right into the code itself: the mathematics of data.

Regardless of the language you are using, whether it is Python, Rust, or Typescript, thinking in terms of Algebraic Data Types (ADTs) allows us to measure and tame this chaos. The key insight is simple but powerful: **To build better programs, we should design functions whose type has the smallest cardinality possible.**

<!--more-->

---

## 1. What Is Cardinality?

In set theory, the "cardinality" of a set is simply a fancy word for the number of distinct elements inside that set. When we apply this to programming, the **cardinality of a type** is the number of valid values that type can possibly hold.

Let’s look at some basic types to see how this works:

*   **/None/ (the unit type):** This has a cardinality of **1**. The only value it can ever hold is /None/.
*   **/bool/:** This has a cardinality of **2**. It can only be /True/ or /False/.
*   **/uint8/ (an 8-bit integer):** This has a cardinality of **256**. It can hold values from 0 up to 255.
*   **/str/:** For all practical purposes, this has an **infinite** cardinality. The number of possible strings is effectively endless. (Of course, in practice, string size is bound by your system's memory)

---

## 2. The Building Blocks: Products, Sums, and Exponents

To analyze our programs mathematically, we can treat our data types as sets and apply basic arithmetic to them.

### Product Types (Multiplication)

When you bundle different pieces of data together, you are multiplying their complexities. In programming, structures like tuples, or dataclasses are known as **product types**.

Mathematically, if you combine Set $A$ and Set $B$ using a cartesian product, the total number of possibilities is $\|A\| \times \|B\|$.

Here is how that looks in Python:

```python
from dataclasses import dataclass

@dataclass
class Point:
    x: bool  # 2 possibilities (True/False)
    y: bool  # 2 possibilities (True/False)

# Total Cardinality: 2 * 2 = 4
```

Because /x/ has 2 possible states and /y/ has 2 possible states, the /Point/ class has 4 distinct possible states.

### Sum Types (Addition)

While bundling data multiplies complexity, providing choices or alternatives adds to it. This is known as a **sum type**.

Mathematically, if a value can be from Set $A$ OR Set $B$, the total possibilities are $\|A\| + \|B\|$.

Python expresses sum types in two primary ways:

**1. Unions**
This is often used for optional values or combining different types.

```python
# The value can be a specific boolean (2 states) OR None (1 state).
# Total Cardinality: 2 + 1 = 3
Result = bool | None
```

**2. Enumerations**
This is the cleanest form of a sum type. An Enum represents a specific set of named variants.

```python
from enum import Enum, auto

class Shape(Enum):
    CIRCLE = auto()
    SQUARE = auto()
    TRIANGLE = auto()

# Total Cardinality: 1 + 1 + 1 = 3
```

### Exponential Types (Exponentiation)

This is where it gets interesting. Functions are actually **exponential types**. If you have a function that takes an input of type $A$ and produces an output type $B$, that function (which remember, is a value) lives in an implementation space of size $B^A$. In other words, the cardinality of the type of functions that when given $A$ produce $B$ is $B^A$.

You can think of a pure function as a lookup table. The inputs ($A$) are the keys, and the outputs ($B$) are the values associated with those keys. How many different tables of this type can you write? $B^A$ tables.

Let’s look at a function signature of /bool -> bool/. Since a boolean has 2 values, the calculation is $2^2 = 4$. This means there are only 4 possible **behaviors** this function can exhibit:

```python
# Implementation 1: Constant True
def always_true(x: bool) -> bool:
    return True

# Implementation 2: Constant False
def always_false(x: bool) -> bool:
    return False

# Implementation 3: Identity (return the input)
def identity(x: bool) -> bool:
    return x

# Implementation 4: Negation (flip the input)
def negation(x: bool) -> bool:
    return False if x else True
```

Or in table form:
```
# The /always_true/ table
+-------+--------+
| Input | Output |
+-------+--------+
| True  | True   |
| False | True   |
+-------+--------+

# The /always_false/ table
+-------+--------+
| Input | Output |
+-------+--------+
| True  | False  |
| False | False  |
+-------+--------+

# The /identity/ table
+-------+--------+
| Input | Output |
+-------+--------+
| True  | True   |
| False | False  |
+-------+--------+

# The /negation/ table
+-------+--------+
| Input | Output |
+-------+--------+
| True  | False  |
| False | True   |
+-------+--------+
```

**A Note on Equivalence:**
When we talk about the cardinality of a function, we are referring to the number of distinct mappings between input and output, not the number of ways you can write the code. All implementations that return the same output for a given input are considered equivalent.

When types are tiny, the number of possible implementations is manageable. However, as types get larger, the space of possible implementations—and therefore the space for potential bugs—explodes.

---

## 3. Argument Lists as Anonymous Products

It is easy to forget that a function's argument list is essentially just an implicit product type.

Consider these two examples:

```python
# Standard argument list
def render(shape: Shape, is_filled: bool) -> None: ...

# Explicit product type
@dataclass
class RenderConfig:
    shape: Shape
    is_filled: bool

def render_wrapped(cfg: RenderConfig) -> None: ...
```

Mathematically, these are identical. Both have an input cardinality of $3 \times 2 = 6$. Every time you add a parameter to a function, you are multiplying the implementation space. Adding just one more boolean flag doesn't add 2 states; it doubles the number of possible implementations of such function.

---

## 4. The Bug Surface Area

We can think of a function's complexity as its "Bug Surface Area." High cardinality means there are more mappings between input and output that you need to verify.

*   **Small Surface Area:** A function with the signature /bool -> bool/ only has 4 possible pure implementations. You can write 2 tests to cover 100% of the behavior.
*   **Large Surface Area:** A function with the signature /str -> Shape/ has $3^\infty$ possibilities. You have to handle /"CIRCLE"/, /"circle"/, /"  circle  "/, /"apple"/, and everything in between.

**The Strategy:**
We should use high-cardinality types, like strings or integers, for external data input. However, we should immediately parse that data into low-cardinality types, like Enums or specific structs. This approach is often called **"Parse, don't validate."** By doing this, the core logic of your application only ever has to deal with a small, manageable implementation space.

---

## 5. Making Invalid States Impossible

One of the best uses of this math is replacing products with sums to eliminate logical contradictions.

### The Product Anti-Pattern

Here is a common way to model the state of a web request:

```python
@dataclass
class State:
    is_loading: bool
    data: str | None
    error: str | None
```

If we treat strings as having $N$ possibilities, the cardinality here is $2 \times (N+1) \times (N+1)$.

The problem is that this structure allows for **impossible states**. For example, /is_loading/ could be /True/ while /error/ is /"Failed"/. Your code will need defensive /if/ statements to handle these confusing combinations.

### The Sum Approach

Instead, we can model this as a sum type:

```python
@dataclass
class Loading:
    pass

@dataclass
class Success:
    data: str

@dataclass
class Failure:
    error: str

# The State can be Loading OR Success OR Failure
State = Loading | Success | Failure
```

The mathematical formula changes from multiplication to addition: $1 + N + N$. More importantly, the invalid states have vanished. It is now structurally impossible for the /Loading/ state to contain an /error/ message.

---

## 6. Refactoring via Isomorphisms

Two types are considered **isomorphic** if they share the same cardinality. This implies there is a one-to-one mapping between them. 

### Example A: Distributing Products into Sums
*Math equivalent: $2 \times 3 = 3 + 3$*

**Product (6 states):**
```python
@dataclass
class Item:
    is_selected: bool
    shape: Shape
```
**Sum (6 states):**
```python
@dataclass
class SelectedItem:
    shape: Shape

@dataclass
class UnselectedItem:
    shape: Shape

Item = SelectedItem | UnselectedItem
```
**Trade-offs:** The Sum version forces you to handle both cases explicitly every time you use pattern matching, increasing safety at the cost of verbosity.

### Example B: Exponents to Products (Logic as Data)
*Math equivalent: $B^A$ treated as a lookup table*

**As a Function:**
```python
class Plan(Enum):
    BASIC = auto()
    PRO = auto()

def get_price(plan: Plan) -> int:
    match plan:
        case Plan.BASIC: return 10
        case Plan.PRO: return 20
```
**As a Table (Product of Ints):**
```python
PRICE_TABLE = { Plan.BASIC: 10, Plan.PRO: 20 }
```
**Trade-offs:** Data (the Table) is serializable and modifiable at runtime. The Function version offers better encapsulation for complex algorithms hiding the implementation from the user.

### Example C: Distributing Exponents over Sums
*Math equivalent: $C^{A+B} \cong C^A \times C^B$*

**The Monolith:**
```python
def handle_event(e: Order | Refund) -> None:
    match e:
        case Order():
            # Logic on how to handle orders
            ...
        case Refund():
            # Logic on how to handle refunds
            ...
```
**Handlers Product:**
```python
from typing import Callable

@dataclass
class EventHandler:
    on_order: Callable[[Order], None]
    on_refund: Callable[[Refund], None]


event_handler = EventHandler(
    on_order=lambda order: ... ,  # Logic on how to handle orders
    on_refund=lambda refund: ...   # Logic on how to handle refunds
)
```
**Trade-offs:** The Monolith keeps the flow in one place. The Handlers Product allows you to swap out specific logic (like the refund handler) without touching the order logic and test them separately.

---

## Conclusion

Understanding the algebra of data types gives us a powerful framework for correct code:

1.  **Count your states:** Use low-cardinality types for core logic.
2.  **Minimize inputs:** Remember that every parameter multiplies complexity.
3.  **Prefer sums to products:** Banish invalid states by making them unrepresentable.
4.  **Refactor algebraically:** Use mathematical isomorphisms to choose the most ergonomic shape for your data.

But above all, minimize the cardinality of your function types to reduce the bug surface area. By doing so, you can write clearer, safer, and more maintainable code.
