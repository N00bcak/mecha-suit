# TypeScript Practices

Follow `package.json`, `tsconfig.json`, workspace scripts, and nearby code
before this primer.

## Idiomatic Defaults

- Prefer functions and discriminated unions for behavior that does not require
  identity or mutable lifecycle.
- Preserve the local error convention: thrown errors, result values, or API
  error objects.
- Release resources in `finally` or with the repository's established
  disposable pattern.
- Await promises deliberately; use bounded concurrency when input size or
  external limits matter.
- Narrow `unknown` at boundaries. Avoid weakening established strictness with
  `any`, non-null assertions, or broad casts.

## Codex Bloat Traps

- Interfaces that mirror one concrete object without a boundary.
- Service classes containing only pass-through methods.
- Generic utility types used once.
- New state management or dependency injection for a local interaction.
- Parallel promises without ownership, cancellation, or rate-limit reasoning.

## Avoid / Prefer

```ts
// Avoid: type assertion bypasses validation.
const payload = input as UserPayload;

// Prefer: narrow through the repository's validator.
const payload = parseUserPayload(input);
```

```ts
// Avoid: wrapper adds no behavior.
const loadUser = (id: string) => client.loadUser(id);

// Prefer:
const user = await client.loadUser(id);
```

## Native Checks

Use package-manager and workspace scripts already present, such as
`npm run format`, `npm run lint`, `npm run typecheck`, and `npm test` (or their
pnpm/yarn/bun equivalents). Do not bypass pinned tooling with global commands.
