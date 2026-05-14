# TypeScript Practices

Reference for writing correct, idiomatic, and maintainable TypeScript in large codebases.

---

## Language Philosophy

TypeScript's value comes from its type system. Use it fully or don't
bother.

- **Strict mode always.** `strict: true` is non-negotiable in any
  project beyond a throwaway script. It catches entire bug categories
  at compile time.
- **Types as documentation.** Well-typed code needs fewer comments.
  The type signature tells you what a function accepts and returns.
- **Make illegal states unrepresentable.** Use discriminated unions,
  branded types, and exhaustive `switch` to make invalid data
  impossible to construct.
- **Structural typing is a feature.** Don't fight it with Java-style
  nominal interfaces. If two types have the same shape, they are
  compatible — use this.
- **Narrow, don't assert.** Prefer type guards and control-flow
  narrowing over `as` casts. If you are casting, you are telling the
  compiler to trust you — and you might be wrong.

## Strict mode

Enable all of these in `tsconfig.json`:

```jsonc
{
    "compilerOptions": {
        "strict": true,                          // enables all strict checks
        "noUncheckedIndexedAccess": true,         // array/object index returns T | undefined
        "exactOptionalPropertyTypes": true,       // distinguishes missing from explicitly undefined
        "noFallthroughCasesInSwitch": true,       // catch missing break in switch
        "forceConsistentCasingInFileNames": true   // prevent case-sensitivity bugs across OS
    }
}
```

- `strict: true` subsumes `strictNullChecks`, `strictFunctionTypes`, `strictBindCallApply`, `noImplicitAny`, and more.
- `noUncheckedIndexedAccess` catches a large class of runtime errors from unguarded array/object access.

## Type safety

- **Avoid `any`**. Use `unknown` for truly unknown types and narrow with type guards.
- **Discriminated unions** over type assertions. Add a `kind` or `type` literal field to distinguish variants.
- **`satisfies` operator** (TS 5.0+): validates a value matches a type while preserving the narrower inferred type. Use when you want both inference and checking.
- **`as const`**: makes literals readonly and narrows to literal types. Prefer over manual type annotations for constant objects and arrays.
- **Avoid non-null assertion (`!`)**: it disables the type checker at that point. Use `?? throw` or an explicit guard instead.
- **Index signatures**: prefer `Record<string, T>` or `Map<K, V>` over `{ [key: string]: T }` for readability. All three require undefined checks with `noUncheckedIndexedAccess`.

## Common pitfalls

| Pitfall | Problem | Fix |
|---|---|---|
| Truthy/falsy confusion | `0`, `""`, `NaN`, `null`, `undefined` are all falsy | Use explicit checks: `x !== null`, `x !== undefined`, `x.length > 0` |
| `==` vs `===` | `==` coerces types: `0 == ""` is `true` | Always use `===` and `!==` |
| Prototype pollution | `Object.assign({}, untrustedInput)` or spread can overwrite `__proto__` | Validate keys; use `Map` for dynamic keys; use `Object.create(null)` |
| `this` binding in callbacks | Class methods lose `this` when passed as callbacks | Use arrow functions, `bind`, or arrow method properties |
| Optional chaining + assignment | `obj?.prop = value` is a syntax error | Guard with `if (obj)` before assignment |
| `for...in` on arrays | Iterates over string keys including inherited properties | Use `for...of`, `.forEach()`, or indexed `for` loop |
| Enum pitfalls | Numeric enums allow reverse mapping and arbitrary number assignment | Prefer `as const` objects or string literal unions |

## Async patterns

- Prefer `async/await` over raw `.then()` chains for readability and stack traces.
- **Unhandled rejections**: every `Promise` must be `await`ed, returned, or explicitly caught. Use `eslint-plugin-no-floating-promises`.
- `Promise.all` rejects on first failure, discarding other results. Use `Promise.allSettled` when you need all outcomes.
- **Sequential vs parallel**: `for (const x of items) { await f(x) }` is sequential. Use `Promise.all(items.map(f))` for parallel.
- **`void` operator for fire-and-forget**: `void someAsyncFn()` signals intentional non-awaiting to linters.
- Never `await` inside a `catch` block without re-throwing if the error should propagate.

## Correctness traps

| Trap | Details |
|---|---|
| `Array.sort()` mutates in place | Returns the same array. Also sorts lexicographically by default: `[10, 2, 1].sort()` gives `[1, 10, 2]`. Pass a comparator: `.sort((a, b) => a - b)` |
| `JSON.parse()` returns `any` | Validate with Zod, io-ts, or a type guard immediately after parsing |
| `typeof null === 'object'` | Historical bug in JavaScript. Check `x === null` explicitly |
| `Number.isNaN` vs `isNaN` | Global `isNaN` coerces: `isNaN("hello")` is `true`. Use `Number.isNaN()` |
| `Date` constructor | `new Date("2024-01-01")` is UTC midnight; `new Date(2024, 0, 1)` is local midnight. Months are 0-indexed |
| Object key coercion | Object keys are always strings. `obj[1]` and `obj["1"]` are the same key. Use `Map` for non-string keys |
| `structuredClone` vs spread | Spread is shallow. `structuredClone()` is deep but cannot clone functions, DOM nodes, or symbols |

## Asymptotic gotchas

| Operation | Cost | Fix |
|---|---|---|
| Object spread in loops | `{...prev, key: val}` copies all keys each iteration: O(n^2) total | Use `Map` or mutate a single object |
| `Array.includes` on large arrays | O(n) per call | Convert to `Set` for repeated membership checks |
| Repeated DOM queries | `document.querySelector` walks the DOM each time | Cache the reference in a variable |
| React unnecessary re-renders | Component re-renders when parent re-renders, even if props unchanged | Use `React.memo`, `useMemo`, `useCallback` at measured bottlenecks |
| String concatenation in loops | O(n^2) from repeated allocation | Collect in array, then `.join('')` |
| `Array.concat` in loops | Creates a new array each time | Use `.push(...items)` or `Array.from` |
| Spread into `Math.max` | `Math.max(...hugeArray)` blows the call stack | Use a manual loop or `reduce` for large arrays |

## Error handling

- **Typed errors**: TypeScript `catch` clause binds `unknown` (with `useUnknownInCatchVariables`). Always narrow before accessing properties.
- **Result pattern**: for functions where failure is expected and common, return `{ ok: true, value: T } | { ok: false, error: E }` instead of throwing. Forces callers to handle both cases.
- **Runtime validation at boundaries**: use Zod, io-ts, or valibot to validate external input (API responses, user input, config files). Trust internal types after validation.
- **Error boundaries in React**: class component `componentDidCatch` or libraries like `react-error-boundary` to prevent full-page crashes.
- Never silently catch and ignore errors. At minimum, log them.

## Testing

- Use Vitest or Jest. Prefer Vitest for new projects (faster, ESM-native, compatible API).
- **Async test patterns**: always `await` assertions on async code. Use `expect(...).rejects.toThrow()` for expected rejections.
- **React Testing Library**: test user behavior, not implementation. Query by role, label, or text — not by test ID or class name.
- Mock external dependencies (APIs, databases, browser APIs). Do not mock internal modules.
- Use `vi.spyOn` / `jest.spyOn` over manual mock implementations when you only need to observe calls.
- Use `msw` (Mock Service Worker) for API mocking in both tests and development.
- Type-check test files. Include test directories in `tsconfig` or use a separate `tsconfig.test.json`.

## Security

| Vector | Risk | Mitigation |
|---|---|---|
| `dangerouslySetInnerHTML` / `innerHTML` | XSS from unsanitized user content | Use framework-safe rendering; sanitize with DOMPurify if raw HTML is required |
| Prototype pollution | Attacker-controlled keys like `__proto__` corrupt object prototypes | Validate object keys; use `Map`; use `Object.create(null)` |
| Template literal SQL | SQL injection: `` `SELECT * FROM t WHERE id = ${id}` `` | Use parameterized queries: `db.query('SELECT * FROM t WHERE id = $1', [id])` |
| CSRF in API routes | State-changing GET requests, missing CSRF tokens | Use POST/PUT/DELETE for mutations; validate origin headers; use CSRF tokens |
| `eval()` / `new Function()` | Arbitrary code execution | Never use with user-controlled input. Use structured parsers |
| Regex DoS (ReDoS) | Catastrophic backtracking on crafted input | Avoid nested quantifiers; use `re2` or safe-regex for user-provided patterns |
| Dependency confusion | Malicious package with same name as internal package | Use scoped packages (`@org/pkg`); configure registry correctly |
