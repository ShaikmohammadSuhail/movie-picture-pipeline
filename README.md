# Movie Picture Pipeline

A fully automated **CI/CD pipeline** (GitHub Actions) that tests, builds, and
deploys a Movie catalog web application to an Amazon EKS cluster.

The application is a 2-tier system:

| Tier     | Stack                              | Source dir |
|----------|------------------------------------|------------|
| Frontend | React (TypeScript-friendly JSX) + Node.js | `frontend/` |
| Backend  | Flask (Python) REST API            | `backend/`  |

On every **pull request** to `main`, GitHub Actions runs **linting**, **unit
tests**, and a **Docker build** for the changed application. On every **push**
(merge) to `main`, the pipeline logs into **Amazon ECR**, pushes the built image
tagged with the git SHA, and deploys the new image to **EKS** via `kubectl` +
`kustomize`.

---

## Repository layout

```
.
├── .github/
│   └── workflows/
│       ├── frontend-ci.yaml      # Frontend Continuous Integration
│       ├── backend-ci.yaml       # Backend Continuous Integration
│       ├── frontend-cd.yaml      # Frontend Continuous Deployment
│       └── backend-cd.yaml       # Backend Continuous Deployment
├── frontend/                     # React application
│   ├── src/
│   ├── public/
│   ├── k8s/                      # Kustomize manifests
│   ├── Dockerfile
│   ├── package.json
│   └── .nvmrc
├── backend/                      # Flask application
│   ├── app.py
│   ├── test_app.py
│   ├── k8s/                      # Kustomize manifests
│   ├── Dockerfile
│   ├── Pipfile
│   └── requirements.txt
├── setup/
│   ├── terraform/                # IaC to provision ECR + EKS
│   └── init.sh                   # Grant github-action-user cluster access
├── README.md
├── RUBRIC_COMPLIANCE_REPORT.md
└── .gitignore
```

---

## Prerequisites (clean machine)

- Git
- Node.js 18 (see `frontend/.nvmrc`)
- Python 3.10 + `pipenv`
- Docker
- `kubectl`, `kustomize`, `aws` CLI (only needed for live deploys)

---

## 1. Local development

### Backend

```bash
cd backend
pipenv install --dev
pipenv run serve          # http://localhost:5000/movies
pipenv run test           # run unit tests
pipenv run lint           # run flake8
```

Expected API response:

```json
{"movies":[{"id":"123","title":"Top Gun: Maverick"},{"id":"456","title":"Sonic the Hedgehog"},{"id":"789","title":"A Quiet Place"}]}
```

### Frontend

```bash
cd frontend
npm ci
CI=true npm test           # run unit tests (3 passing)
npm run lint               # eslint (no errors)
REACT_APP_MOVIE_API_URL=http://localhost:5000 npm start
```

---

## 2. Continuous Integration (pull request → `main`)

Triggered automatically on `pull_request` against `main` **and only when the
respective application directory changes** (`paths:` filter). Each workflow can
also be triggered manually via **workflow_dispatch**.

Jobs (run in parallel, then a `needs:` gated build):

1. **lint** – checkout, setup runtime, restore cache, install, run linter.
2. **test** – checkout, setup runtime, restore cache, install, run tests.
3. **build** – runs `docker build` **only after** lint & test succeed
   (`needs: [lint, test]`). The frontend build injects
   `REACT_APP_MOVIE_API_URL` via `--build-arg`.

If any step fails, the pipeline fails (no green build on broken tests).

---

## 3. Continuous Deployment (push / merge → `main`)

Triggered automatically on `push` to `main` **and only when the respective
application directory changes**. Each workflow can also be triggered manually
via **workflow_dispatch**.

Jobs:

1. **lint** – lint the code.
2. **test** – run the unit tests.
3. **build** – after lint & test pass (`needs: [lint, test]`), configure AWS
   credentials from **GitHub Secrets**, log into ECR with
   `aws-actions/amazon-ecr-login`, build the Docker image (frontend uses
   `--build-arg REACT_APP_MOVIE_API_URL`) and **push** it to ECR tagged with
   the git SHA (`${{ github.sha }}`).
4. **deploy** – update kubeconfig for EKS, set the image tag in the Kustomize
   manifests (`kustomize edit set image`), apply with `kubectl apply -f -`,
   and verify the rollout.

### Required GitHub Secrets

| Secret                | Purpose                                 |
|-----------------------|-----------------------------------------|
| `AWS_ACCESS_KEY_ID`    | IAM user credentials for GitHub Actions |
| `AWS_SECRET_ACCESS_KEY`| IAM user credentials for GitHub Actions |
| `AWS_REGION`          | e.g. `us-east-1`                        |
| `EKS_CLUSTER_NAME`    | e.g. `cluster`                          |

> **Security:** No AWS credentials are hardcoded anywhere in the workflows.
> They are injected exclusively from encrypted GitHub Secrets.

---

## 4. Provisioning the environment (optional)

```bash
cd setup/terraform
terraform init
terraform apply          # creates 2 ECR repos + an EKS cluster
terraform output         # capture repo URLs / cluster name

# Grant the github-action-user access to the cluster (run once)
cd ../..
aws eks update-kubeconfig --name cluster --region us-east-1
./setup/init.sh
```

Tear down afterwards with `terraform destroy`.

---

## 5. Manual Docker verification

```bash
# Backend
cd backend && docker build --tag mp-backend:latest .
docker run -p 5000:5000 --rm -d mp-backend
curl http://localhost:5000/movies

# Frontend
cd frontend && docker build --build-arg=REACT_APP_MOVIE_API_URL=http://localhost:5000 --tag mp-frontend:latest .
docker run -p 3000:3000 --rm -d mp-frontend
# open http://localhost:3000
```

---

## Submission evidence

- Four GitHub Actions workflow files under `.github/workflows/`.
- `RUBRIC_COMPLIANCE_REPORT.md` contains the full line-by-line rubric audit.
- Frontend returns the movie list; backend `/movies` returns the JSON above.

### Submission Notes

> **GitHub repository (public):** `https://github.com/ShaikmohammadSuhail/movie-picture-pipeline`
>
> **Frontend EKS Service URL:** `http://adae87aa58fc541d7b623e5d8b4c9c9b-324425899.us-east-1.elb.amazonaws.com`
>   - e.g. `http://ae0a1b2c...us-east-1.elb.amazonaws.com`
>   - Browser screenshot with this URL visible, showing the movie list.
>
> **Backend EKS Service URL:** `http://a83658a5bd2cb4ff8b485d4ed6d9e392-928142772.us-east-1.elb.amazonaws.com:5000/movies`
>   - e.g. `http://de0f1a2b...us-east-1.elb.amazonaws.com:5000/movies`
>   - Browser screenshot with this URL visible, showing the JSON list of movies.
>
> **kubectl get all:** capture the terminal screenshot after `kubectl get all`
>   - `kubectl get all` should show the `mp-frontend` and `mp-backend`
>     deployments, pods, and both services in `Running` state.

After filling in the three placeholders above, this README fulfills the
reviewer's requirement to provide the public GitHub link and the deployed
application URLs.

### How to get the public URLs and screenshots

The frontend and backend are both exposed publicly via Kubernetes Services
configured as `type: LoadBalancer`. After the CD workflows deploy the apps,
retrieve the public URLs with:

```bash
cd setup
./get_submission_evidence.sh
```

Submission-ready evidence set:
- Public GitHub link to the repository (all 4 workflows with successful run
  records under GitHub Actions).
- Frontend EKS Service URL, or a screenshot of the frontend via that URL
  showing the movie list (URL visible in the address bar).
- Backend EKS Service URL, or a screenshot of `/movies` via that URL showing
  the JSON response (URL visible in the address bar).
- Screenshot of `kubectl get all`.
- If the infrastructure is torn down before review (to save credits), the
  above three screenshots satisfy the requirement without live URLs.
