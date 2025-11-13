---
title: "IBM watsonx & Agentic AI"
author: "Ruslas Magana Vsevolodovna"
date: "2025-11-12"
---

# Introduction to Agentic AI

This document/presentation explores the emerging field of Agentic AI, with a focus on IBM watsonx capabilities.

## What is Agentic AI? {data-transition="slide"}
Agentic AI refers to systems designed to autonomously perceive, reason, plan, and act in complex environments to achieve specific goals.

- Autonomy
- Goal-oriented behavior
- Adaptability and learning

**Key idea:** Beyond prompt→response; agents can proactively plan & act.

## IBM watsonx.ai for Agents {data-transition="fade"}
IBM watsonx.ai provides foundational models and tooling to build, deploy, and govern Agentic AI solutions.

- Foundation models
- Prompt tooling
- Governance (data, risk, policies)

```python
# Example: Conceptual LLM call (illustrative)
# Official SDKs and model IDs change over time; check IBM docs for the latest.
# from ibm_watsonx_ai import Model
# model = Model(model_id="...")  # configure auth & project first
# print(model.generate("Explain Agentic AI in one sentence."))
```

::: notes
Speaker note: call out governance and evaluation early for enterprise readers.
:::

## Building an Agent {data-background-color="#0f172a" data-transition="convex" data-background-transition="zoom"}
1. Define the goal (task & success metrics)  
2. Select tools (APIs, DB, search, calculator, internal services)  
3. Orchestrate control flow (tool choice, planning, retries)  
4. Evaluate, observe, iterate (offline & online)

```bash
# Conceptual CLI flow (placeholder)
agent-builder create my-wx-agent --goal "answer customer queries" --llm "..."
agent-builder deploy my-wx-agent --env production
```

## Ethical Considerations {data-transition="fade"}
- Transparency & observability  
- Bias & fairness checks  
- Accountability & human oversight


## Neural Network Forward Pass {data-background-color="#1a1a1a"}

The forward propagation for a single layer is:

$$z^{[l]} = W^{[l]}a^{[l-1]} + b^{[l]}$$

$$a^{[l]} = g^{[l]}(z^{[l]})$$

where:
- $W^{[l]}$ is the weight matrix
- $b^{[l]}$ is the bias vector
- $g^{[l]}$ is the activation function
- $a^{[l]}$ is the activation output

**Common Activation Functions:**

$$\text{ReLU}(x) = \max(0, x)$$

$$\text{Sigmoid}(x) = \frac{1}{1 + e^{-x}}$$

$$\text{Tanh}(x) = \frac{e^x - e^{-x}}{e^x + e^{-x}}$$