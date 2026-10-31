# Contributing

## Branch model

| Branch      | Purpose                                   | Rules |
|-------------|-------------------------------------------|-------|
| `main`      | Production, always deployable             | PR only, from `develop`, `release/*` or `hotfix/*`. Protected. |
| `develop`   | **Default branch**, integration of work   | PR only. Protected. CI must pass. |
| `feature/*` | New functionality                         | Branch from `develop`, PR into `develop` |
| `fix/*`     | Non-urgent bug fixes                      | Branch from `develop`, PR into `develop` |
| `hotfix/*`  | Urgent production fixes                   | Branch from `main`, PR into `main` **and** `develop` |
| `release/*` | Release prep (e.g. `release/1.2.0`)       | Branch from `develop`, PR into `main` |
| `chore/*` `docs/*` `refactor/*` `test/*` `ci/*` | Housekeeping | Branch from `develop`, PR into `develop` |

## Branch naming

```
<type>/<area>-<issue#>-<short-kebab-description>
```

- `type`: feature, fix, hotfix, release, chore, docs, refactor, test, ci
- `area` (optional but recommended): `backend`, `frontend`, `shared`
- lowercase, words separated with `-`

Examples:
```
feature/backend-12-add-product-api
feature/frontend-15-cart-page
fix/frontend-21-navbar-overflow
hotfix/backend-30-token-expiry
release/1.0.0
```

## Commit messages (Conventional Commits)

```
<type>(<scope>): <summary in imperative mood>
```

- types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- scopes: `backend`, `frontend`, `ci`, `repo`
- Examples: `feat(backend): add product CRUD endpoints`, `fix(frontend): correct cart total`

PR titles use the same format (checked by CI). Use **squash merge** so `develop` history stays clean.

## Pull requests

1. Open the PR against `develop` (or `main` for hotfix/release).
2. CI must be green and at least 1 approval from a code owner.
3. Resolve all conversations, then squash-merge and delete the branch.

## Local checks before pushing

```bash
cd backend  && npm run lint && npm test
cd frontend && npm run build
```

## Versioning & releases

Semantic Versioning. Merge `release/x.y.z` into `main`, tag `vX.Y.Z`, then merge `main` back into `develop`.
