---
layout: default
title: "Prompt Futamura Projections"
---

# Prompt Futamura Projections

In computer science, the [**Futamura Projections**](https://en.wikipedia.org/wiki/Partial_evaluation) are a legendary concept connecting interpreters, compilers, and partial evaluators. They act as a bridge between "running code" and "compiling code."

But what happens if we treat **Natural Language** as our programming code, and an **LLM** as our processor?

Can we "compile" an English instruction? Can we build a "Compiler Generator" out of pure prose?

I decided to test the three Futamura Projections using LLMs (specifically GPT-4/Claude 3). The goal isn't to write Python or C code, but to use English as the **Domain Specific Language (DSL)**, exploring how prompts can recursively optimize themselves.

## The Primitives: Setting the Stage

To make this work, we need three distinct components (our primitives).

### 1. The Code ($P$)
Since Natural Language is our DSL, our "source code" is just a specific instruction we want to execute.
*   **Example:** *"Translate the user input into purely Emoji icons."*

### 2. The Interpreter ($I$)
This is a generic System Prompt. It doesn't know *what* to do until we pass it the Code. It essentially acts as a runtime environment for our instructions.
*   **Prompt:**
> "You are a Universal Executor. I will provide you with an **Instruction** and a **User Input**. You must apply the Instruction to the User Input and return the result."

### 3. The Specializer ($S$)
In the Futamura equations, this is the **Partial Evaluator**. Its job is to take a generic program and some static data, and "bake" the data into the program to make it faster and more specific.
*   **Prompt:**
> "You are a Prompt Specializer.
> I will give you a **Base Prompt** and a **Static Parameter**.
> Your goal is to rewrite the Base Prompt so that the Static Parameter is permanently 'baked' into the logic of the prompt. The new prompt should no longer ask for that parameter, as it is now hard-coded context.
> Output only the rewritten prompt."

---

## Projection 1: The Compiled Program
**The Equation:** $Target = S(I, P)$

The first projection is the most intuitive. We want to turn our general **Interpreter** and our specific **Code** into a standalone "Application." We want to strip away the overhead of the interpreter logic.

**The Experiment:**
We feed the **Specializer ($S$)** the following inputs:
1.  **Base:** The Interpreter ($I$)
2.  **Static Param:** *"Translate user input into Emojis"* ($P$)

**The LLM Output:**
> "You are an Emoji Translator. When you receive User Input, strictly translate that input into a sequence of Emoji icons representing the text. Do not perform any other actions."

**The Verdict:**
Success. The LLM successfully "compiled" the instruction. The output prompt no longer asks for an instruction; it *is* the instruction.

---

## Projection 2: The Compiler
**The Equation:** $Compiler = S(S, I)$

Here is where it gets "meta." We are going to use the Specializer to process... the Specializer.

We want to create a prompt that generates apps. We want to fix the **Interpreter** as the permanent context. We are asking: *"Create a version of the Specializer that is hard-coded to always specialize the Universal Executor."*

**The Experiment:**
We feed the **Specializer ($S$)** the following inputs:
1.  **Base:** The Specializer ($S$)
2.  **Static Param:** The Interpreter ($I$)

**The LLM Output:**
> "You are a Prompt Compiler.
> I will provide you with a specific **Natural Language Instruction**.
> You must instantly generate a specialized System Prompt that executes that instruction. You are essentially converting a rough instruction into a dedicated System Prompt Persona."

**The Verdict:**
We have successfully generated a **Compiler**.
If you paste this output into a new chat, you can simply type "Summarize text like a 1920s gangster," and it will immediately output a full System Prompt designated for that task. We have automated Prompt Engineering.

---

## Projection 3: The Compiler Generator (Cogen)
**The Equation:** $Cogen = S(S, S)$

This is the "Brain Melt" layer. This is the Third Futamura Projection.

We are feeding the Specializer into itself, *with itself* as the static parameter. The goal is to create a tool that can generate Compilers for *any* type of interpreter structure, not just our "Universal Executor."

**The Experiment:**
We feed the **Specializer ($S$)** the following inputs:
1.  **Base:** The Specializer ($S$)
2.  **Static Param:** The Specializer ($S$)

**The LLM Output:**
> "You are a Compiler Generator.
> I will provide you with a **Target Interpreter Prompt** (e.g., a standard Executor, a Moralizing Executor, or a Concise Executor).
> You must output a **Compiler Prompt**. That resulting Compiler Prompt will effectively convert Instructions into specialized agents that run specifically on your provided Interpreter logic."

### Verification: Does it work?
To test if this result was hallucinatory or functional, I took the output (The Cogen) and fed it a strange, new Interpreter:
*   **New Interpreter:** *"You are a XML-Bot. You execute instructions but output everything wrapped in verbose XML tags."*

The **Cogen** processed this and outputted a **New Compiler**:
> "You are an XML-Prompt Generator. Give me a task, and I will generate a System Prompt that forces the AI to perform that task and wrap the output in XML tags."

**The Verdict:**
It works. The LLM understood the abstract relationship between the prompt structure and the specialization engine.

---

## Conclusion

By applying the Futamura Projections to prompts, we prove that Natural Language in LLMs behaves remarkably like code in functional programming.

1.  **Projection 1** creates **Apps** (Specific Prompts).
2.  **Projection 2** creates **Factories** (Prompt Generators).
3.  **Projection 3** creates **Factory Builders** (Generator Generators).

This implies that "Prompt Engineering" isn't just an art; it's a recursive syntactic process that can be automated, compiled, and optimized using the very models we are trying to control.
