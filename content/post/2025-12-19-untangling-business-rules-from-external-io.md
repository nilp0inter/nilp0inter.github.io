---
title: "Untangling Business Rules from External IO: A Practical Python Guide"
date: 2025-12-19T12:00:00Z
slug: "untangling-business-rules-from-external-io"
categories: ["software"]
years: ["2025"]
draft: false
math: true
---


A common challenge in application development is the entanglement of business rules with external operations (like database writes or API calls). When these mix, testing becomes difficult, and error handling often degrades into a web of *try/except* blocks that hide the actual flow of logic.

This post explores a practical pattern to solve these specific problems. By treating program outcomes as data rather than exceptions, and by isolating external side effects from core logic, we can create code that is easier to read, safer to refactor, and simpler to test.

<!--more-->

---

## 1. The Philosophy: Exceptions vs. Variants

In this approach, we distinguish between **System Crashes** and **Business Decisions**.

1.  **System Failures (The Unexpected):**
    *   *Examples:* Disk full, Syntax Error, Database Definition Mismatches.
    *   *Strategy:* **Let them bubble.** The logic cannot fix a full disk. These fly up to the application entry point (or your framework's middleware) to be logged as 500 errors.
2.  **World-Errors (The Decision Triggers):**
    *   *Examples:* An API timeout, a rate limit, a bank denial.
    *   *Strategy:* **Catch and Transform.** We catch these at the edge (where we talk to the API) and return them as **Data**. If the logic needs to decide what to do when a bank is "Busy," that "Busy" state is no longer an exception—it is input data.
3.  **Domain Failures (The Expected):**
    *   *Examples:* Insufficient funds, User banned.
    *   *Strategy:* **Return Data.** These are valid logic branches modeled as specific data structures.

---

## 2. Modeling Data with Sum Types

We use *dataclasses* and the **\|** operator (Union types) to model outcomes. We carefully separate **Infrastructure results** (what the gateway said) from **Logical results** (what that means for our application).

```python
from dataclasses import dataclass
from typing import Callable, ContextManager, assert_never

# --- Entities ---
@dataclass(frozen=True)
class Account:
    id: str
    balance: float

# --- Infrastructure Variants (The "World" output) ---
@dataclass(frozen=True)
class PaymentOK:
    txn_id: str

@dataclass(frozen=True)
class PaymentDenied:
    reason: str

# Note: Timeout is a recognized state, not an exception
@dataclass(frozen=True)
class PaymentTimeout:
    wait_seconds: int

PaymentResult = PaymentOK | PaymentDenied | PaymentTimeout

# --- Application Variants (The Use-Case output) ---
@dataclass(frozen=True)
class TransferSuccess:
    txn_id: str
    remaining_balance: float

@dataclass(frozen=True)
class TransferDeclined:
    reason: str

@dataclass(frozen=True)
class SystemUnavailable:
    message: str

TransferResult = TransferSuccess | TransferDeclined | SystemUnavailable
```

---

## 3. The Logic Factory

We use a **Higher-Order Function** to handle dependency injection. The outer function accepts the functional dependencies (like database readers or API clients), and returns the inner function (the actual logic) ready to be executed.

### Sequencing Side-Effects
We structure the logic to keep **External IO** (Slow/Unreliable) separate from **Internal State Updates** (Atomic/Critical). This ensures we only modify local state after we receive confirmation from the external world.

```python
def make_transfer_funds(
    *,
    fetch_account: Callable[[str], Account | None],
    save_account: Callable[[Account], None],
    debit_external: Callable[[float], PaymentResult],
    unit_of_work: ContextManager
) -> Callable[[str, float], TransferResult]:

    def transfer_funds(sender_id: str, amount: float) -> TransferResult:
        # 1. Validation (Pre-Check)
        sender_preview = fetch_account(sender_id)
        if not sender_preview:
            return TransferDeclined(reason="Account not found")
        
        # 2. External World Actions (The "Impure" Phase)
        # We perform the slow external call outside the unit of work
        payment = debit_external(amount)

        # 3. Decision & Persistence (The "Atomic" Phase)
        match payment:
            case PaymentOK(txn_id):
                with unit_of_work:
                    # In this atomic phase, we ensure we act on the latest data
                    sender_uptodate = fetch_account(sender_id)
                    
                    if not sender_uptodate:
                        return TransferDeclined(reason="Account disappeared")

                    new_balance = sender_uptodate.balance - amount
                    
                    if new_balance < 0:
                        return TransferDeclined(reason="Insufficient funds")

                    # Functional update: Create new, don't mutate old
                    updated_account = Account(sender_uptodate.id, new_balance)
                    save_account(updated_account)

                    return TransferSuccess(
                        txn_id=txn_id,
                        remaining_balance=new_balance
                    )

            case PaymentDenied(reason):
                return TransferDeclined(reason=reason)

            case PaymentTimeout(wait):
                return SystemUnavailable(message=f"Bank busy, retry in {wait}s")
            
            case _ as unreachable:
                assert_never(unreachable)

    return transfer_funds
```

---

## 4. The Edge: Adapters and Wiring

"Adapters" handle the messy HTTP/Driver details. Note that *unit_of_work* is injected abstractly, letting us swap generic drivers for testing drivers easily.

```python
import requests

# --- Adapter (Infrastructure) ---
def stripe_debit_adapter(amount: float) -> PaymentResult:
    try:
        resp = requests.post("https://api.stripe.com/v1/debit", json={"amt": amount}, timeout=2)
        if resp.status_code == 200:
            return PaymentOK(resp.json()['id'])
        return PaymentDenied(resp.json()['error'])
    except requests.Timeout:
        return PaymentTimeout(wait_seconds=30)

# --- Wiring ---
import db_driver

# We build the function once at startup
transfer_funds = make_transfer_funds(
    fetch_account=db_driver.get_account,
    save_account=db_driver.save_account,
    debit_external=stripe_debit_adapter,
    unit_of_work=db_driver.transaction_atomic()
)
```

---

## 5. The Imperative Shell

The entry point (e.g., a FastAPI or Django view) treats the result as data. We use *assert_never* in the match block to ensure that if we add a new result type later (e.g., *FraudDetected*), our static analysis (MyPy) will force us to handle it here.

```python
def api_view(request):
    try:
        # Call the 'compiled' use case
        result = transfer_funds(request.json["sender_id"], request.json["amount"])
        
        match result:
            case TransferSuccess(txn_id, bal):
                return {"status": "success", "txn": txn_id, "balance": bal}
            
            case TransferDeclined(reason):
                return {"status": "error", "message": reason}, 400
            
            case SystemUnavailable(msg):
                return {"status": "retry", "message": msg}, 503
            
            case _ as unreachable:
                # If we add a new logic branch but forget to handle it here,
                # MyPy will error out before we ever deploy.
                assert_never(unreachable)
                
    except Exception as e:
        # Framework middleware usually handles this, but for clarity:
        # These are the "System Failures" (Disk full, Logic bugs)
        logger.critical(f"System Crash: {e}", exc_info=True)
        return {"status": "fatal"}, 500
```

---

## 6. Type-Safe Stubs (Mocking without Mocks)

We avoid *unittest.mock* because it can be brittle; it mocks objects based on *names*. If you rename a method, the mock keeps passing, but the production code fails.

Here, we mock based on **Signatures**. We use standard Python functions (lambdas) as stubs. If the logic requirements change, the static analyzer ensures our test stubs are updated to match.

```python
from contextlib import nullcontext

def test_successful_transfer_updates_balance_safely():
    # 1. Setup Environment
    # We use a mutable list to inspect the side-effect (the save)
    saved_accounts = []
    
    # A simple stub that simulates the DB return
    def db_stub(uid):
        return Account(uid, 1000.00)

    stub_logic = make_transfer_funds(
        fetch_account=db_stub,
        save_account=saved_accounts.append,
        debit_external=lambda amt: PaymentOK("txn_123"),
        unit_of_work=nullcontext()
    )
    
    # 2. Act
    result = stub_logic("user_1", 100.00)
    
    # 3. Assert Result
    assert isinstance(result, TransferSuccess)
    assert result.remaining_balance == 900.00
    
    # 4. Assert State Change
    assert len(saved_accounts) == 1
    assert saved_accounts[0].balance == 900.00

def test_api_timeout_logic_mapping():
    # Simulate API failure
    stub_logic = make_transfer_funds(
        fetch_account=lambda uid: Account(uid, 1000.00),
        save_account=lambda acc: None,
        debit_external=lambda amt: PaymentTimeout(wait_seconds=30),
        unit_of_work=nullcontext()
    )
    
    result = stub_logic("user_1", 100.00)
    
    # Ensure Domain properly mapped the "World Error" to a "Decision"
    assert isinstance(result, SystemUnavailable)
    assert "retry in 30s" in result.message
```

---

## Conclusion

This approach is about bringing clarity to the boundary where your code meets the real world.

**When we mix IO errors with logic errors, we force ourselves to hold the entire system's state in our heads just to write a unit test. By untangling them, we break the problem in two: Adapters handle the messy, unpredictable world of HTTP and SQL, while Logic handles the deterministic rules of the business.**

By converting "World Errors" into data, we ensure our business logic remains a clean room of predictable decisions. This doesn't mean we ignore failures; it means we categorize them. We reserve **Exceptions** for truly **irrecoverable errors**—the system crashes, like a full disk or a broken database connection, that should properly bubble up to an error monitoring tool like Sentry. 

By treating business branches as data and system panics as exceptions, we finally return to the original intent of the language: **we only use Exceptions for truly *exceptional* situations.**
