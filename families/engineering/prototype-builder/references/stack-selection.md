# Stack Selection

Decision aid for choosing a technology stack for prototypes. Optimize for speed to working demo, not production readiness.

## Core Principle

The prototype proves the idea, not the stack. Pick fast, move on.

## Decision Table by Task Type

| Task Type | Recommended Stack | Why |
|---|---|---|
| CLI tool | Python (or Go if distribution matters) | Fast to write, batteries included; Go produces a single static binary |
| Web app (frontend only) | HTML/CSS/JS or React/Vue + Vite | Minimal setup, instant reload, zero backend |
| Web app (full-stack) | Next.js, Flask/FastAPI, or Rails | One deploy target, one primary language, built-in patterns |
| REST API | FastAPI (Python) or Express (Node) | Auto-generated docs/validation (FastAPI), huge middleware ecosystem (Express) |
| GraphQL API | Apollo Server (Node) or Strawberry (Python) | Schema-first development, built-in playground |
| Data pipeline / ETL | Python + pandas/polars | Best library ecosystem for tabular data, Jupyter for exploration |
| Desktop app | Electron or Tauri | Cross-platform using web skills; Tauri for smaller binary size |
| Mobile app | React Native or Flutter | Cross-platform, fast iteration, hot reload |
| Browser extension | Vanilla JS or React | Chrome/Firefox APIs are JS-native, minimal bundling needed |
| System tool / daemon | Go or Rust | Single binary, no runtime dependency, good concurrency |
| ML experiment | Python + Jupyter | Standard ecosystem (PyTorch, scikit-learn, HuggingFace) |
| Automation / scripting | Python or Bash | Available everywhere, quick to write |
| Static site / docs | Astro, Hugo, or plain HTML | Fast build, free hosting (Netlify, GitHub Pages, Vercel) |
| Game prototype | Godot (GDScript) or Unity (C#) | Visual editor, asset pipeline, fast iteration |
| Hardware / embedded | C or MicroPython | Depends on target constraints (memory, real-time requirements) |

## Decision Heuristics

Use these in order. The first decisive factor wins.

### 1. What does the builder already know?

Familiarity dominates for prototypes. A competent Rails developer ships a Rails prototype faster than a "better-suited" stack they've never used. Only break this rule when the known stack genuinely cannot do the job.

### 2. Does a critical library only exist in one language?

If the prototype depends on a specific library (e.g., a particular ML model only available in Python, a system API only accessible from C), that constrains the choice. Build around the library.

### 3. What deploys easiest to the target?

| Target | Easiest deployment |
|---|---|
| Share a link | Vercel, Netlify, Railway (web apps) |
| Send to non-technical user | Go/Rust binary, Electron app, mobile app |
| Run on server | Docker container, any language |
| Run on user's machine | Python script (if Python installed), Go binary (no deps) |
| Embedded / IoT | C, Rust, MicroPython |

### 4. What matches the team / future maintainers?

If the prototype will graduate to production with a specific team, match their stack now to avoid a rewrite.

## Anti-Patterns

| Anti-pattern | Why it kills prototypes |
|---|---|
| Picking a new framework you've never used | You'll spend more time learning the framework than building the prototype |
| Over-configuring build tools | Webpack configs, complex Dockerfiles, CI pipelines -- skip all of this for a prototype |
| Adding TypeScript to a 100-line script | Type safety overhead exceeds script complexity; add types when it grows |
| Premature microservices | One process, one database, one deploy. Split later if it survives |
| Building auth from scratch | Use an auth provider (Clerk, Auth0, Supabase Auth) or skip auth entirely for the prototype |
| Choosing the "best" stack over the "known" stack | There is no best stack. There is only the stack that gets you to a demo fastest |
| Setting up a monorepo for one app | Monorepo tooling (Nx, Turborepo) is overhead. Start with a single directory |
| Database per prototype | SQLite or a managed Postgres instance covers most prototypes |

## When to Break the Table

The decision table is a default. Override it when:

- **User explicitly prefers a stack.** Respect stated preferences. A prototype the builder is comfortable with gets iterated on. A prototype in an unfamiliar stack gets abandoned.
- **Specific library constraint.** If the prototype needs `whisper.cpp`, you're in C++. If it needs `langchain`, you're in Python. The library picks the language.
- **Deployment target constrains.** AWS Lambda favors Python/Node. iOS-only means Swift. Cloudflare Workers means JS/Wasm.
- **Performance is the hypothesis.** If the prototype exists to prove something can be fast enough, pick the fast language (Rust, Go, C++) from the start. Rewriting for speed later invalidates the prototype's findings.
- **Interop requirement.** Extending an existing system in language X means the prototype should also be in language X (or have a clean FFI story).

## Stack Comparison Quick Reference

### Language tradeoffs for prototypes

| Language | Strengths for prototyping | Weaknesses for prototyping |
|---|---|---|
| Python | Fastest to write, best libraries for data/ML/scripting | Slow runtime, packaging/distribution is painful |
| JavaScript/TS | Runs everywhere (browser, server, mobile), huge npm ecosystem | Dependency bloat, async complexity |
| Go | Fast compile, single binary output, good stdlib | Verbose error handling, less expressive |
| Rust | Correct and fast output | Slow to write, steep learning curve for prototypes |
| Ruby (Rails) | Convention over configuration, rapid CRUD apps | Smaller ecosystem outside web, slower runtime |
| Java/Kotlin | Strong typing, mature ecosystem, good IDE support | Verbose setup, slow cold start |
| C/C++ | Maximum control and performance | Slow development, manual memory management |
| Swift | iOS/macOS native, safe, expressive | Apple ecosystem only |
| Dart (Flutter) | Cross-platform mobile with single codebase | Smaller ecosystem outside Flutter |

### Database selection for prototypes

| Need | Use |
|---|---|
| Just need persistence | SQLite (zero setup, single file) |
| Relational data, multi-user | PostgreSQL via managed service (Supabase, Neon, Railway) |
| Document store / flexible schema | MongoDB Atlas or Firestore |
| Key-value / caching | Redis or in-memory dict/map |
| Full-text search | SQLite FTS5, or Elasticsearch if scale demands it |
| Vector search (ML/RAG) | pgvector, Qdrant, or Pinecone |
| Don't know yet | SQLite. Migrate later. |
