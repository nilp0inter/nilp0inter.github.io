---
title: "PACE Planning: Why Your \"Solid\" Backup Plan Is Probably Fragile"
date: 2026-01-08T12:00:00Z
slug: "pace-planning-fragile-backups"
categories: ["software", "resilience"]
years: ["2026"]
draft: false
math: false
---

We tell ourselves we're prepared. We have backups. We have redundancies. Software engineers pride themselves on avoiding Single Points of Failure (SPOF).

But often, when chaos actually strikes (a server outage, a natural disaster, or just a really bad Monday), we find our backup plans were little more than lists of things we *hoped* would work.

A framework exists to cure this optimism bias: **PACE planning**.

It originated in the military, specifically for Special Ops comms plans. I’ve found it to be an incredibly potent tool for engineering resilience and personal peace of mind. It transforms "trying to figure it out on the fly" into a structured algorithm for continuity.

Simply writing a PACE plan down on a napkin isn't enough, though. If you don't understand your dependencies, even a four-layer backup plan can collapse in seconds.

<!--more-->

## The PACE Breakdown

PACE is an acronym determining the order of precedence for methods used to achieve a critical goal, or "mission." It forces you to define four distinct ways to get the job done:

*   **P - Primary:** The preferred method. It's the most efficient, effective, and habitual way you execute the task.
*   **A - Alternate:** The iconic "Plan B." It should be nearly as effective as the Primary, often running in parallel or available with minimal friction.
*   **C - Contingency:** "Plan C." Here is where things get annoying. Ideally, the Contingency method is reliable but less convenient, slower, or more resource-intensive.
*   **E - Emergency:** The last resort. "Plan D." usually serves as a break-glass method. It will likely be slow, expensive, or provide only minimum viability, but it prevents total mission failure.

One crucial nuance in the formal definition of PACE often gets ignored: the four methods must be **"independent enough that failure of one does not break the others."**

That logical condition, *independent enough*, is the hardest part to get right.

## When It Works: The Coffee Run

To see this in action, let’s apply it to a low-stakes, critical daily mission: **Getting Morning Coffee.**

*   **Primary:** The Espresso Machine (Fast, delicious, routine).
*   **Alternate:** The French Press (Slower cleanup, requires a separate kettle, but good quality).
*   **Contingency:** Instant Coffee (Tastes worse, requires boiling water, very fast).
*   **Emergency:** A canned energy drink from the fridge (Cold, different chemical profile, but delivers the caffeine payload).

**Why is this a good plan?**
The dependencies are physically distinct.
If the Espresso machine's electronics fail, the low-tech French Press works. If the electric kettle breaks, you can boil water in a pot on your **gas stove**. If the power goes out entirely, the gas still flows to boil the water. If the gas line is cut, the cold energy drink in the fridge requires no heat source at all.

Getting a PACE plan right for small missions is easy because the physics remain visible to the naked eye.

## Where It Breaks: Hidden Interdependencies

Trouble starts when we apply "Napkin PACE Planning" to complex systems like IT infrastructure or Incident Response where the dependencies are abstract and invisible.

Consider a scenario many of us face: **Remote Incident Response.**

**The Mission:** You are the on-call engineer. You need to SSH into a production database to clear a deadlock during a critical launch.

You feel safe. You scribbled down a PACE plan:

*   **Primary:** Home Fiber Internet (Wi-Fi).
*   **Alternate:** 5G Hotspot via Mobile Phone.
*   **Contingency:** The Coworking Space/Coffee Shop down the street.
*   **Emergency:** Voice call a colleague in a different region to dictate commands.

On the surface, this looks robust. Theoretically, you have three layers of redundancy before you have to resort to the awkward phone call.

**The Event:** A transformer blows, causing a wide-area power outage in your neighborhood.

**The Cascade:**
1.  **Primary Fails:** Your router goes dark immediately. You switch to your phone.
2.  **Alternate Fails:** Here's the nuance. The local cell tower *has* a battery backup, so the signal is live. But 10,000 of your neighbors just lost their Wi-Fi simultaneously. They all switched to 5G at the exact same second to check Twitter and complain to the power company. The congestion is so high that your SSH packets are dropped.
3.  **Contingency Fails:** You grab your laptop and run to the coffee shop. You forgot that "The Coffee Shop" shares a hidden dependency with "Home Fiber": **Geography**. They are on the same electrical grid substation. The shop is dark and locked.

**The Result:**
In under 60 seconds, your plan collapsed from Primary straight to Emergency. You are now clutching your phone, praying that voice traffic gets prioritized over the 5G data congestion that just killed your Alternate plan, hoping the call actually goes through.

## The Transitive Dependency Problem

Why did the Remote Work plan fail while the Coffee plan succeeded?

It failed because we confuse **Methods** with **Resources**, and we ignore that dependencies are **transitive**.

On the napkin, we think:
`Primary Method -> Home Router` (in this context "`->`" means "depends on")

In reality, the dependency graph is transitive:
`Primary Method -> Home Router -> Power Grid`

Map out the other methods, and you'll see they all converge on the same transitive node:
*   `Contingency (Coffee Shop) -> Shop Open -> Power Grid`
*   `Alternate (5G) -> Cell Tower -> Finite Bandwidth` (An exhaustible resource shared by your neighbors, who are also reacting to the Power Grid failure).
*   `Emergency (Call Colleague) -> Cell Tower -> Finite Bandwidth` (Now competing with the congestion).

When we design systems informally, we act as if the *failure of the method* is the only risk (e.g., "The router broke"). We rarely model the *failure of the transitive resources* (e.g., "The neighborhood has no power").

### Visualizing the Failure

Graph these dependencies out, and the fragility becomes obvious.

Check the diagram below for two things:
1.  **The "Phone" bottleneck:** Both your Alternate (Hotspot) and Emergency (Voice Call) plans rely on a single physical device. If you drop your phone in the panic, you lose 50% of your PACE plan instantly.
2.  **The Failure Cascade:** The red nodes represent the root failure. When the **Regional Power Grid** fails, it knocks out the Primary and Contingency methods directly. But it also creates a massive spike in traffic that saturates the **RF Bandwidth**, effectively choking off your Alternate and Emergency channels.

```mermaid
graph TD
    classDef method fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef resource fill:#fff9c4,stroke:#fbc02d,stroke-width:2px,color:black;
    classDef failure fill:#ffcdd2,stroke:#c62828,stroke-width:3px,color:black;

    Goal((Mission: <br>Incident Response)) --> P[Primary: <br>Home Fiber]
    Goal --> A[Alternate: <br>5G Hotspot]
    Goal --> C[Contingency: <br>Coffee Shop]
    Goal --> E[Emergency: <br>Voice Call]

    subgraph "Hidden Shared Dependencies"
        P --> Router --> HomePower
        C --> ShopWiFi --> ShopPower
        
        A --> Phone
        E --> Phone
        
        A --> CellTower
        E --> CellTower
        
        CellTower --> RF[RF Bandwidth]
        
        HomePower --> Grid[Regional Power Grid]
        ShopPower --> Grid
    end

    %% The Cascasde
    Grid -.- |Failure Causes Congestion| RF

    class P,A,C,E method;
    class Router,Phone,CellTower,HomePower,ShopWiFi,ShopPower resource;
    class Grid,RF failure;
```

### Awareness vs. Invincibility

Quick disclaimer before going further: **You can always break a PACE plan if you zoom out far enough.**

Dependency graphs are fractals. Dig deep enough and you'll always find a shared dependency that can topple the whole stack.
*   If a massive earthquake forces you to evacuate your home, you aren't going to have your morning coffee, regardless of whether you have a French Press or a gas stove.
*   If you suffer a medical emergency like a stroke, you won't be clearing that database lock even if you have four different internet connections.

There's always a "Black Swan" event (a meteor, a war, or biology itself) that creates a total failure state.

The goal of this exercise, and of the tools we are about to explore, isn't to create a theoretically bulletproof plan for the apocalypse. The goal is to **know the limits** of the plan you *do* have.

We want to move from "I hope this works" to "I know exactly why this might fail." We want to catch the preventable, logical errors like shared power grids so we aren't blindsided by the mundane, all while accepting the risks of the catastrophic.

## Beyond the Napkin

A PACE plan is only as good as the independence of its layers. If failure of the Primary layer triggers a condition that propagates down a transitive chain to kill the Alternate and Contingency layers, you don't actually have a plan. You have a hallucination of safety.

For critical systems, we need to be able to mathematically prove that our "Plan B" is actually available when "Plan A" dies. We need to move from intuition to verification.

Next time, I'll explore how we can use **Formal Methods** (specifically **TLA+**) to model these resources and find hidden problems. We will move beyond scribbling on napkins and start verifying our resilience strategies with the same rigor we use to verify distributed systems.

*Stay tuned.*
