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
