# Workflow: Ship This Idea

Turn one founder sentence into the smallest useful shipped product.

## Trigger

```text
ship this idea: [one sentence]
```

## Flow

1. Product reads context and asks at most three material questions.
2. Product writes `PRODUCT_BRIEF.md` with recommended assumptions.
3. Designer writes `DESIGN.md` and defines responsive acceptance criteria.
4. Builder implements the smallest complete version.
5. Reviewer checks the user journey, visuals, accessibility, and health.
6. Security checks release risk.
7. Ops deploys when credentials are present and observes logs.
8. Product records what shipped and the next growth/learning step.

## Founder Gates

Ask for approval only for credentials, paid generation, publication, production
release, rollback, destructive action, or licensed media.

## Verification

- Working build or URL is returned.
- Missing setup is reduced to one concrete blocker.
- Product, design, test, and deploy evidence are saved.
