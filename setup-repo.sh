#!/usr/bin/env bash
# Scaffolds rn-smartElectronic: backend (Node/Express) + frontend (React/Vite/Tailwind),
# GitHub Actions CI, PR/branch conventions. Run from inside the empty repo folder.
set -euo pipefail

mkdir -p backend/src backend/test frontend/src .github/workflows .github/ISSUE_TEMPLATE

# ---------------------------------------------------------------- root files
cat > README.md <<'EOF'
# rn-smartElectronic

Monorepo with two apps:

| Folder      | Stack                          | Dev port |
|-------------|--------------------------------|----------|
| `backend/`  | Node.js + Express              | 5000     |
| `frontend/` | React + Vite + Tailwind CSS    | 5173     |

## Getting started

```bash
# backend
cd backend && cp .env.example .env && npm install && npm run dev

# frontend (new terminal)
cd frontend && npm install && npm run dev
```

## Workflow

- Default branch: **`develop`**. Production branch: **`main`**.
- Read [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming, commit format and PR rules.
EOF

cat > .gitignore <<'EOF'
node_modules/
dist/
build/
coverage/
.env
.env.*
!.env.example
*.log
.DS_Store
.vscode/
.idea/
EOF

cat > .editorconfig <<'EOF'
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
EOF

cat > .gitattributes <<'EOF'
* text=auto eol=lf
EOF

cat > .nvmrc <<'EOF'
20
EOF

cat > .github/CODEOWNERS <<'EOF'
# Every PR needs review from the reviewer; add teammates per folder as the team grows.
*            @hrh2
/backend/    @hrh2
/frontend/   @hrh2
/.github/    @hrh2
EOF

cat > .github/pull_request_template.md <<'EOF'
## What does this PR do?
<!-- Short summary -->

## Related issue
Closes #

## Area
- [ ] backend
- [ ] frontend
- [ ] CI / tooling / docs

## How was it tested?
<!-- Commands run, screenshots for UI -->

## Checklist
- [ ] Branch name follows the convention
- [ ] PR title follows Conventional Commits (`feat(frontend): ...`)
- [ ] Lint, tests and build pass locally
- [ ] No secrets or `.env` files committed
EOF

cat > .github/ISSUE_TEMPLATE/bug_report.md <<'EOF'
---
name: Bug report
about: Something is broken
labels: bug
---
**Area:** backend / frontend
**What happened?**
**Expected behaviour**
**Steps to reproduce**
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md <<'EOF'
---
name: Feature request
about: Propose a new feature
labels: enhancement
---
**Area:** backend / frontend
**Problem / motivation**
**Proposed solution**
EOF

cat > .github/dependabot.yml <<'EOF'
version: 2
updates:
  - package-ecosystem: npm
    directory: /backend
    target-branch: develop
    schedule: { interval: weekly }
  - package-ecosystem: npm
    directory: /frontend
    target-branch: develop
    schedule: { interval: weekly }
  - package-ecosystem: github-actions
    directory: /
    target-branch: develop
    schedule: { interval: weekly }
EOF

cat > CONTRIBUTING.md <<'EOF'
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
EOF

# ---------------------------------------------------------------- workflows
cat > .github/workflows/backend-ci.yml <<'EOF'
name: Backend CI

on:
  push:
    branches: [main, develop]
    paths: ['backend/**', '.github/workflows/backend-ci.yml']
  pull_request:
    branches: [main, develop]
    paths: ['backend/**', '.github/workflows/backend-ci.yml']

concurrency:
  group: backend-${{ github.ref }}
  cancel-in-progress: true

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: backend
    strategy:
      matrix:
        node-version: [20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm
          cache-dependency-path: backend/package-lock.json
      - run: npm ci
      - run: npm run lint
      - run: npm test
EOF

cat > .github/workflows/frontend-ci.yml <<'EOF'
name: Frontend CI

on:
  push:
    branches: [main, develop]
    paths: ['frontend/**', '.github/workflows/frontend-ci.yml']
  pull_request:
    branches: [main, develop]
    paths: ['frontend/**', '.github/workflows/frontend-ci.yml']

concurrency:
  group: frontend-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: frontend
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci
      - run: npm run build
EOF

cat > .github/workflows/pr-checks.yml <<'EOF'
name: PR Checks

on:
  pull_request:
    types: [opened, edited, synchronize, reopened]
    branches: [main, develop]

permissions:
  pull-requests: read

jobs:
  pr-title:
    name: Conventional PR title
    runs-on: ubuntu-latest
    steps:
      - uses: amannn/action-semantic-pull-request@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          types: |
            feat
            fix
            docs
            style
            refactor
            perf
            test
            build
            ci
            chore
            revert
          scopes: |
            backend
            frontend
            ci
            repo
          requireScope: false

  branch-name:
    name: Branch naming convention
    runs-on: ubuntu-latest
    steps:
      - name: Validate head branch name
        env:
          BRANCH: ${{ github.head_ref }}
        run: |
          regex='^((feature|fix|hotfix|chore|docs|refactor|test|ci)/[a-z0-9]+(-[a-z0-9]+)*|release/[0-9]+\.[0-9]+\.[0-9]+|dependabot/.+)$'
          if [[ "$BRANCH" =~ $regex ]] || [[ "$BRANCH" == "develop" && "${{ github.base_ref }}" == "main" ]]; then
            echo "Branch '$BRANCH' is valid."
          else
            echo "::error::Branch '$BRANCH' does not match the convention. See CONTRIBUTING.md (e.g. feature/backend-12-add-product-api)."
            exit 1
          fi
EOF

# ---------------------------------------------------------------- backend
cat > backend/package.json <<'EOF'
{
  "name": "rn-smartelectronic-backend",
  "version": "0.1.0",
  "private": true,
  "main": "src/server.js",
  "engines": { "node": ">=20" },
  "scripts": {
    "start": "node src/server.js",
    "dev": "node --watch src/server.js",
    "lint": "eslint .",
    "test": "node --test test/"
  },
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.21.0",
    "helmet": "^8.0.0",
    "morgan": "^1.10.0"
  },
  "devDependencies": {
    "@eslint/js": "^9.12.0",
    "eslint": "^9.12.0",
    "globals": "^15.11.0"
  }
}
EOF

cat > backend/eslint.config.js <<'EOF'
const js = require('@eslint/js');
const globals = require('globals');

module.exports = [
  { ignores: ['node_modules/', 'coverage/'] },
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'commonjs',
      globals: { ...globals.node },
    },
    rules: {
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
];
EOF

cat > backend/.env.example <<'EOF'
PORT=5000
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173
EOF

cat > backend/src/app.js <<'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || 'http://localhost:5173' }));
app.use(express.json());
if (process.env.NODE_ENV !== 'test') app.use(morgan('dev'));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'rn-smartelectronic-backend' });
});

app.use((_req, res) => res.status(404).json({ error: 'Not found' }));

// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(err.status || 500).json({ error: err.message || 'Internal server error' });
});

module.exports = app;
EOF

cat > backend/src/server.js <<'EOF'
require('dotenv').config();
const app = require('./app');

const port = process.env.PORT || 5000;
app.listen(port, () => console.log(`Backend listening on http://localhost:${port}`));
EOF

cat > backend/test/health.test.js <<'EOF'
const { test } = require('node:test');
const assert = require('node:assert');
const app = require('../src/app');

test('GET /health returns ok', async () => {
  const server = app.listen(0);
  try {
    const { port } = server.address();
    const res = await fetch(`http://127.0.0.1:${port}/health`);
    assert.strictEqual(res.status, 200);
    assert.strictEqual((await res.json()).status, 'ok');
  } finally {
    server.close();
  }
});
EOF

cat > backend/README.md <<'EOF'
# Backend (Node.js + Express)

```bash
cp .env.example .env
npm install
npm run dev     # http://localhost:5000/health
npm run lint
npm test
```
EOF

# ---------------------------------------------------------------- frontend
cat > frontend/package.json <<'EOF'
{
  "name": "rn-smartelectronic-frontend",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@tailwindcss/vite": "^4.0.0",
    "@vitejs/plugin-react": "^4.3.3",
    "tailwindcss": "^4.0.0",
    "vite": "^5.4.10"
  }
}
EOF

cat > frontend/vite.config.js <<'EOF'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    proxy: { '/api': 'http://localhost:5000' },
  },
});
EOF

cat > frontend/index.html <<'EOF'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Smart Electronic</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

cat > frontend/src/index.css <<'EOF'
@import "tailwindcss";
EOF

cat > frontend/src/main.jsx <<'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
EOF

cat > frontend/src/App.jsx <<'EOF'
export default function App() {
  return (
    <main className="min-h-screen grid place-items-center bg-slate-900 text-white">
      <h1 className="text-3xl font-bold">rn-smartElectronic</h1>
    </main>
  );
}
EOF

cat > frontend/README.md <<'EOF'
# Frontend (React + Vite + Tailwind CSS)

```bash
npm install
npm run dev      # http://localhost:5173  (proxies /api -> :5000)
npm run build
```
EOF

echo
echo "Scaffold created. Next steps:"
echo "  (cd backend && npm install) && (cd frontend && npm install)   # generates package-lock.json (needed by CI)"
echo "  git add -A && git commit -m 'chore(repo): scaffold monorepo, CI and conventions'"
echo "  git push -u origin main"
echo "  git checkout -b develop && git push -u origin develop"
echo "  then set 'develop' as default branch on GitHub (see notes)."
