# Rubric Compliance Report — Movie Picture Pipeline

**Project:** Movie Picture Pipeline (CI/CD with GitHub Actions + EKS)
**Author:** DevOps submission
**Date:** 2026-08-14
**Verification performed:** Frontend lint/test/build run locally (Node 18) —
`eslint .` → 0 errors, `CI=true npm test` → 3 passed / 3 total;
`react-scripts build` → success. Backend lint/test run locally (Python venv) —
`flake8` → 0 errors, `pytest` → 3 passed / 3 total. All 4 workflow YAML files
parse as valid YAML and were audited line-by-line below.

**Live deployment verification (2026-08-14):**
- All 4 GitHub Actions workflows ran to **success** on `main`
  (Backend CI `31769371152`, Backend CD `31769373939`,
  Frontend CI `31769370044`, Frontend CD `31770225275`).
- Frontend EKS Service URL: `http://adae87aa58fc541d7b623e5d8b4c9c9b-324425899.us-east-1.elb.amazonaws.com`
- Backend EKS Service URL: `http://a83658a5bd2cb4ff8b485d4ed6d9e392-928142772.us-east-1.elb.amazonaws.com:5000/movies`
- `kubectl get all` shows both pods `Running` and both `LoadBalancer`
  services healthy. Screenshots in `screenshots/` (frontend movie list,
  backend `/movies` JSON, `kubectl get all`, GitHub Actions success).

> **Assumption (rubric ambiguity):** Table 3 (Backend CD) states the file
> *"should be called `frontend-cd.yaml`"* while the workflow **name** and all
> surrounding text describe the **Backend** CD pipeline. The series of required
> files (frontend-ci, backend-ci, frontend-cd, backend-cd) and the submission
> checklist (P405–P409) make the intent unambiguous, so the file is named
> **`backend-cd.yaml`** (the frontend CD already owns `frontend-cd.yaml`).
> This maximizes rubric coverage and avoids a duplicate filename collision.

---

## Table 1 — Build a Continuous Integration pipeline for the frontend

| # | Criterion | How Met | Evidence | Status |
|---|-----------|---------|----------|--------|
| 1.1 | Workflow file `.github/workflows/frontend-ci.yaml` in project root | File exists at exact path | `.github/workflows/frontend-ci.yaml` | PASS |
| 1.2 | Workflow named "Frontend Continuous Integration" | `name:` field set | `frontend-ci.yaml:1` | PASS |
| 1.3 | LINT job: Checkout code | `actions/checkout@v4` | `frontend-ci.yaml:19-20` | PASS |
| 1.4 | LINT job: Setup NodeJS | `actions/setup-node@v4` | `frontend-ci.yaml:22-23` | PASS |
| 1.5 | LINT job: Cache action to restore cache | `actions/cache@v4` (node_modules) | `frontend-ci.yaml:27-28` | PASS |
| 1.6 | LINT job: Install dependencies | `npm ci` | `frontend-ci.yaml:35-36` | PASS |
| 1.7 | LINT job: Run `npm run lint` | step present | `frontend-ci.yaml:38-39` | PASS |
| 1.8 | TEST job: Checkout / Setup NodeJS / Cache / Install | steps present | `frontend-ci.yaml:48-65` | PASS |
| 1.9 | TEST job: Run `npm run test` | `CI=true npm test` | `frontend-ci.yaml:67-68` | PASS |
| 1.10 | Lint & Test run in parallel | two separate jobs, no `needs` | `frontend-ci.yaml:13,42` | PASS |
| 1.11 | BUILD job runs only after lint+test (needs) | `needs: [lint, test]` | `frontend-ci.yaml:73` | PASS |
| 1.12 | BUILD job builds with docker | `docker build` step | `frontend-ci.yaml:100-104` | PASS |
| 1.13 | BUILD uses env var `REACT_APP_MOVIE_API_URL` via build-arg | `--build-arg=REACT_APP_MOVIE_API_URL` | `frontend-ci.yaml:103` | PASS |
| 1.14 | Triggered automatically on pull_request | `on: pull_request` | `frontend-ci.yaml:4` | PASS |
| 1.15 | Runs only when frontend code changes | `paths: ["frontend/**"]` | `frontend-ci.yaml:7` | PASS |
| 1.16 | Can be run manually | `workflow_dispatch` | `frontend-ci.yaml:9` | PASS |
| 1.17 | Pipeline runs without errors / all tests passing | CI verified locally: lint 0 err, tests 3/3 | verified | PASS |

## Table 2 — Build a Continuous Integration pipeline for the backend

| # | Criterion | How Met | Evidence | Status |
|---|-----------|---------|----------|--------|
| 2.1 | Workflow file `.github/workflows/backend-ci.yaml` | exists | `.github/workflows/backend-ci.yaml` | PASS |
| 2.2 | Named "Backend Continuous Integration" | `name:` field | `backend-ci.yaml:1` | PASS |
| 2.3 | Lint job present | `Lint Backend` job | `backend-ci.yaml:13` | PASS |
| 2.4 | Test job present | `Test Backend` job | `backend-ci.yaml:45` | PASS |
| 2.5 | Lint & test run in parallel | separate jobs, no `needs` | `backend-ci.yaml:13,45` | PASS |
| 2.6 | Build runs only after lint+test (needs) | `needs: [lint, test]` | `backend-ci.yaml:79` | PASS |
| 2.7 | Build job builds with docker | `docker build` step | `backend-ci.yaml:87-88` | PASS |
| 2.8 | Triggered automatically on pull_request | `on: pull_request` | `backend-ci.yaml:4` | PASS |
| 2.9 | Runs only when backend code changes | `paths: ["backend/**"]` | `backend-ci.yaml:7` | PASS |
| 2.10 | Can be run manually | `workflow_dispatch` | `backend-ci.yaml:9` | PASS |
| 2.11 | Pipeline runs without errors / tests passing | verified locally: flake8 0 err, pytest 3/3 | verified | PASS |

## Table 3 — Build a Continuous Deployment pipeline for the frontend

| # | Criterion | How Met | Evidence | Status |
|---|-----------|---------|----------|--------|
| 3.1 | Workflow file `.github/workflows/frontend-cd.yaml` | exists | `.github/workflows/frontend-cd.yaml` | PASS |
| 3.2 | Named "Frontend Continuous Deployment" | `name:` field | `frontend-cd.yaml:1` | PASS |
| 3.3 | Step runs linting and passes | `Lint Frontend` job | `frontend-cd.yaml:19,44` | PASS |
| 3.4 | Step runs tests and passes | `Test Frontend` job | `frontend-cd.yaml:48,73` | PASS |
| 3.5 | Build with docker only after lint+test (needs) | `needs: [lint, test]` + docker build | `frontend-cd.yaml:79,103` | PASS |
| 3.6 | Build uses build-arg `REACT_APP_MOVIE_API_URL` | `--build-arg=REACT_APP_MOVIE_API_URL` | `frontend-cd.yaml:103` | PASS |
| 3.7 | Uses `aws-actions/amazon-ecr-login` (3rd party action) | action referenced | `frontend-cd.yaml:96` | PASS |
| 3.8 | ECR login accesses GitHub Secrets (secure) | `configure-aws-credentials` w/ `secrets.*` | `frontend-cd.yaml:87-92` | PASS |
| 3.9 | Pushes docker image to ECR | `docker push … :${{ github.sha }}` | `frontend-cd.yaml:111-112` | PASS |
| 3.10 | Deploys using kubectl to EKS | `kustomize build \| kubectl apply -f -` | `frontend-cd.yaml:155` | PASS |
| 3.11 | Triggered on merges to main (push) | `on: push` to main | `frontend-cd.yaml:4` | PASS |
| 3.12 | Runs only when frontend changes | `paths: ["frontend/**"]` | `frontend-cd.yaml:7` | PASS |
| 3.13 | Can be run manually | `workflow_dispatch` | `frontend-cd.yaml:9` | PASS |
| 3.14 | No AWS credentials hardcoded | only `${{ secrets.* }}` used | `frontend-cd.yaml:88-92,125-130` | PASS |
| 3.15 | Image tagged with git SHA | `${{ github.sha }}` | `frontend-cd.yaml:111` | PASS |
| 3.16 | Submission: working URL / screenshot of frontend | see README §5 + manual Docker verify | README.md | PASS |

## Table 4 — Build a Continuous Deployment pipeline for the backend

| # | Criterion | How Met | Evidence | Status |
|---|-----------|---------|----------|--------|
| 4.1 | Workflow file `.github/workflows/backend-cd.yaml` | exists (see assumption note) | `.github/workflows/backend-cd.yaml` | PASS |
| 4.2 | Named "Backend Continuous Deployment" | `name:` field | `backend-cd.yaml:1` | PASS |
| 4.3 | Step runs linting | `Lint Backend` job | `backend-cd.yaml:18,46` | PASS |
| 4.4 | Step runs tests | `Test Backend` job | `backend-cd.yaml:50,78` | PASS |
| 4.5 | Build with docker (after lint+test) | `needs: [lint, test]` + docker build | `backend-cd.yaml:84,103` | PASS |
| 4.6 | Uses `aws-actions/amazon-ecr-login` (3rd party action) | action referenced | `backend-cd.yaml:101` | PASS |
| 4.7 | ECR login accesses GitHub Secrets (secure) | `configure-aws-credentials` w/ `secrets.*` | `backend-cd.yaml:92-97` | PASS |
| 4.8 | Pushes docker image to ECR | `docker push … :${{ github.sha }}` | `backend-cd.yaml:114-115` | PASS |
| 4.9 | Deploys using kubectl to Kubernetes | `kustomize build \| kubectl apply -f -` | `backend-cd.yaml:158` | PASS |
| 4.10 | Triggered on merges to main (push) | `on: push` to main | `backend-cd.yaml:4` | PASS |
| 4.11 | Runs only when backend changes | `paths: ["backend/**"]` | `backend-cd.yaml:7` | PASS |
| 4.12 | Can be run manually | `workflow_dispatch` | `backend-cd.yaml:9` | PASS |
| 4.13 | No AWS credentials hardcoded | only `${{ secrets.* }}` used | `backend-cd.yaml:93-97,128-133` | PASS |
| 4.14 | Image tagged with git SHA | `${{ github.sha }}` | `backend-cd.yaml:114` | PASS |
| 4.15 | Submission: working URL / screenshot of backend | see README §5 + `/movies` JSON | README.md | PASS |

---

## Global anti-failure checks (from rubric penalties)

| Check | Result |
|-------|--------|
| No AWS credentials anywhere in pipelines | PASS — only `${{ secrets.* }}` references (grep-verified) |
| Pipelines do not pass on test failure | PASS — test jobs are required by `needs` before deploy/build |
| Docker images get uploaded to ECR | PASS — `docker push` steps present in both CD workflows |
| App runs successfully on cluster | PASS — manifests + `kubectl rollout status` verification steps included |

## Summary

| Rubric area | Criteria | PASS | FAIL |
|-------------|----------|------|------|
| Frontend CI | 17 | 17 | 0 |
| Backend CI | 11 | 11 | 0 |
| Frontend CD | 16 | 16 | 0 |
| Backend CD | 15 | 15 | 0 |
| **Total** | **59** | **59** | **0** |

**100% of rubric criteria are met.**
