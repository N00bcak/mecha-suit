# Skill Selection Examples

## Collaboration

- "Help me turn this rough product idea into a coherent concept" -> `product-co-design`
- "Pressure-test this service idea and identify what we need to validate" -> `product-co-design`
- "Interview me about what I want from this project" -> `interview-me` (explicit invocation only)

## Engineering

- "Fix this one-line parsing bug in a 50k-line service" -> `large-codebase-change`
- "Edit this existing 2k-line utility" -> native Codex
- "Build a new isolated CSV viewer web app" -> `prototype-builder`
- "Create a greenfield CLI that converts JSON to CSV" -> `prototype-builder`
- "Migrate the database schema in this large service" -> `large-codebase-change`; load its migration reference
- "Update Python and TypeScript callers in this large polyglot repository" -> `large-codebase-change`; load only the Python and TypeScript primers

## CTF

- "Here is a challenge prompt and files, where do I start?" -> `ctf-triage`
- "Reverse this stripped ELF validation binary" -> `reverse-ctf`
- "Exploit this heap challenge against a remote service" -> `pwn-ctf`
- "This challenge gives me an RSA public key and ciphertext" -> `crypto-ctf`
- "There's a web app running on port 8080, find the flag" -> `web-ctf`
- "Analyze this PCAP file for hidden data" -> `forensics-ctf`
- "Escape this Python sandbox to read the flag" -> `misc-ctf`
- "I have a challenge binary and a crypto script, not sure which is the real target" -> `ctf-triage`
- "Bypass this LLM chatbot's guardrails to extract the flag" -> `ai-ctf`
- "Generate an adversarial image that fools this classifier" -> `ai-ctf`

## AI

- "Use ai-pipeline to frame this churn problem end to end" -> `ai-pipeline` (explicit invocation only)
- "Classify these columns, quantify missingness, and package a clean dataset" -> `ai-data-preparation`
- "Find and validate meaningful cohort or temporal patterns in this dataset" -> `ai-insight-development`
- "Build leakage-safe features for these sensor windows" -> `ai-representation-workbench`
- "Choose between boosted trees, a neural model, and a hybrid for this task" -> `ai-problem-modeling`
- "Train and compare these candidates under the agreed split and metrics" -> `ai-performance`
- "Design a state representation and admissible heuristic for this planner" -> `ai-representation-workbench`
- "Benchmark and tune this constraint solver on representative instances" -> `ai-performance`

## Native clarification and council

- "Help with my project" -> native clarification; no skill yet
- "Assess an ML-powered security challenge that needs reverse engineering and modeling judgment" -> `interdisciplinary-council` using `reverse-ctf` and the relevant AI execution leaf
- "This web CTF challenge has a backend I need to modify and exploit" -> `web-ctf` (one specialist is sufficient; engineering context is incidental)
- "Integrate a security audit tool into this codebase and verify it catches the known vuln classes" -> `interdisciplinary-council` (engineering + CTF perspectives both needed)
