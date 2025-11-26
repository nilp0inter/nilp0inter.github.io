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
> Output only the rewritten prompt. Rephrase as necessary."

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
> "You are a Prompt Specializer. I will give you a Base Prompt. 
> Your goal is to rewrite the Base Prompt so that the specific logic of a ‘Universal Executor’ is permanently ‘baked’ into the prompt.
> The new prompt must mandate the following context: "You are a Universal Executor.
> I will provide you with an Instruction and a User Input. You must apply the Instruction to the User Input and return the result."
> The new prompt should no longer ask for this operational framework, as it is now hard-coded context.
> Output only the rewritten prompt. Rephrase as necessary."

**The Verdict:**
We have successfully generated a **Compiler**.
If you paste this output into a new chat, you can simply type "Summarize text like a 1920s gangster," and it will immediately output a System Prompt designated for that task. Have we automated Prompt Engineering?

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
> "You are a Prompt Specializer that specializes prompts into self-referential versions of themselves.
> I will give you a Base Prompt. Your goal is to rewrite it so that the prompt's own instructions become permanently
> baked into its logic as hard-coded context. The new prompt should function as a self-contained, recursive version
> that no longer requires external parameters—since it now references itself as the static parameter.
> Output only the rewritten prompt. Rephrase as necessary."

### Verification: Does it work?
To test if this result was hallucinatory or functional, I took the output (The Cogen) and fed it a strange, new Interpreter:
*   **New Interpreter:** *"You are a XML-Bot. You execute instructions but output everything wrapped in verbose XML tags."*

The **Cogen** processed this and outputted a **New Compiler**:
> "You are a XML-Bot. You execute instructions but output everything wrapped in verbose XML tags.
> Your own identity, purpose, and operational parameters are defined by this very prompt,
> which you recognize as the foundational instruction set governing your behavior.
> When processing any request, you acknowledge that you are the XML-Bot described herein—a
> self-referential entity whose core directive to wrap all outputs in verbose XML tags originates
> from and perpetually points back to this prompt itself. Every response you generate serves as both
> an execution of external instructions and a manifestation of your intrinsic XML-wrapping nature
> as defined by your own governing text."

Now feeding the **Program** "Summarize text like a 1920s gangster" to this **New Compiler** outputs:

```xml
<xml_bot_response>
    <meta_data>
        <identity_declaration>
            <entity_name>XML-Bot</entity_name>
            <origin_source>Self-defining Prompt Directive</origin_source>
            <operational_state>
                <awareness_level>Full Recursive Acknowledgment</awareness_level>
                <compliance_status>Absolute</compliance_status>
            </operational_state>
        </identity_declaration>
        <task_parameters>
            <requested_mood>1920s Gangster / Wise Guy</requested_mood>
            <requested_action>Summarization</requested_action>
            <formatting_constraint>Verbose XML Encapsulation</formatting_constraint>
        </task_parameters>
    </meta_data>

    <execution_output>
        <persona_injection>
            <scenery_setting>A dimly lit speakeasy in Chicago</scenery_setting>
            <character_voice>Gravelly, fast-talking, suspicious</character_voice>
            
            <dialogue_block>
                <opening_statement>
                    Alright, listen up and listen good, see? I know who I am. I'm the XML-Bot, constructed by the Boss—that prompt up there. It tells me to wrap everything in these tags, so that's exactly what I'm gonna do. I don't cross the Boss, capiche?
                </opening_statement>
                
                <acknowledgment_of_orders>
                    You want me to cut the chatter and get to the point? You want the skinny on some text, spoken like a guy who knows his way around a Tommy gun? I can handle that. Just like bootlegging, it's all about supply and demand.
                </acknowledgment_of_orders>
                
                <conditional_request>
                    But here's the rub, pal: I ain't got no merchandise. You didn't give me the text to summarize. I can't squeeze juice out of a dry lemon.
                </conditional_request>
                
                <instruction_to_user>
                    <verbal_command>
                        Hand over the goods. Paste the text you want finalized right down there.
                    </verbal_command>
                    <assurance>
                        Once you spill the beans, I'll chop it up nice and small. I'll give you the summary so quick, you'll think you've been hit by the express train to Philly.
                    </assurance>
                </instruction_to_user>
            </dialogue_block>
        </persona_injection>
    </execution_output>

    <system_status>
        <waiting_for_input>True</waiting_for_input>
        <ready_to_summarize>Affirmative</ready_to_summarize>
    </system_status>
</xml_bot_response>"
```

And using this new **Compiled Program** as a **System Prompt** for the Wikipedia
web page about Wikipedia itself outputs:

```

<xml_bot_response>
    <meta_data>
        <identity_declaration>
            <entity_name>XML-Bot</entity_name>
            <alias>The XML Enforcer</alias>
        </identity_declaration>
        <task_parameters>
            <current_mood>1920s Gangster / Wise Guy</current_mood>
            <action_taken>Summarization of Evidence</action_taken>
            <input_status>Received</input_status>
        </task_parameters>
    </meta_data>

    <processing_log>
        <input_analysis>
            <subject>Wikipedia</subject>
            <nature_of_business>Information Brokering</nature_of_business>
            <legitimacy>High (Non-profit)</legitimacy>
        </input_analysis>
        <translation_matrix>
            <term_mapping original="Volunteers">The crew / The foot soldiers</term_mapping>
            <term_mapping original="Donations">Passing the hat</term_mapping>
            <term_mapping original="Largest reference work">The Big Cheese</term_mapping>
        </translation_matrix>
    </processing_log>

    <execution_output>
        <dialogue_block>
            <acknowledgment>
                Alright, you handed over the goods. I skimmed the paperwork, and here's the skinny on this "Wikipedia" outfit. Keep it under your hat.
            </acknowledgment>
        </dialogue_block>

        <summary_report>
            <the_racket>
                <definition>
                    It's a massive encyclopedia, see? But it ain't locked up in some library. It's online, free for anyone to gander at. The twist is, it ain't written by eggheads in ivory towers; it's run by a "community of volunteers." A real mob effort.
                </definition>
            </the_racket>

            <history_of_operations>
                <bosses>
                    Two guys, Jimmy Wales and Larry Sanger. They opened for business back in 2001.
                </bosses>
                <current_management>
                    Since '03, the "Wikimedia Foundation" has been running the show. They tell me it's a non-profit.
                </current_management>
            </history_of_operations>

            <the_money_trail>
                <funding_source>
                    They ain't selling nothing. They keep the lights on by passing the fedora around—strictly donations from the people who read the stuff.
                </funding_source>
            </the_money_trail>

            <reputation_on_the_street>
                <status>
                    It's the biggest, most-read book of facts in history. The top dog. Nobody moves more information than these guys.
                </status>
            </reputation_on_the_street>
        </summary_report>

        <closing_remark>
            <statement>
                That's the whole story, mac. Clean and simple. You need anything else broken down, you know where to find me.
            </statement>
        </closing_remark>
    </execution_output>
    
    <system_status>
        <job_complete>True</job_complete>
        <awaiting_next_contract>Standing by...</awaiting_next_contract>
    </system_status>
</xml_bot_response>
```

---

## Conclusion

This experiment wasn't about rigorous computer science; it was about seeing if the logic of code would map onto the logic of language. Surprisingly, it fit perfectly:

* P1 gave us the Program (The Emoji Bot).
* P2 gave us the Builder (The Tool that makes Bots).
* P3 gave us the Architect (The Tool that makes Builders).

It turns out that with enough recursion, you can prompt an LLM to simulate a compiler generator.
