# .idx/airules.md
# Configuration file for Project IDX AI assistance.
# Provides context and rules for this Python/GCP project using Taskfile and Docker.
# Based on: https://developers.google.com/idx/guides/airules

# --- GENERATE: Define files included in codebase context ---
GENERATE:
  include:
    - scripts/**/*.py        # Python source code (assuming it will be here)
    - app/**/*.py           # Alternative common location for Python code
    - main.py               # Common entrypoint name
    - requirements.txt      # Main Python dependencies
    - requirements-dev.txt  # Development dependencies (if present)
    - Taskfile.yaml         # Task definitions are crucial context
    - Dockerfile            # Container definition (important when added)
    - README.md             # Project overview and setup instructions
    - templates/**/*        # Include files in the templates directory
    - .gitignore            # Excluded files provide context
    - .idx/dev.nix          # Nix environment definition (if present)
    - *.yaml                # Include other YAML files (e.g., configs)
    - *.json                # Include JSON files (e.g., configs)

  exclude:
    - .git/**               # Git internal files
    - .venv/**              # Python virtual environment
    - __pycache__/**        # Python bytecode cache
    - .idx/**               # Exclude AI rules itself and other IDX dynamic config
    - .vscode/**            # Usually user-specific editor settings
    - ai_context.txt        # Generated context file from Taskfile 'ai' task
    - *.log                 # Log files
    - .env                  # Environment variables (potentially sensitive)
    - secrets/              # Exclude potential secrets directory
    - secret*.json          # Common pattern for local secret files (use with care)
    - build/                # Common build output directory
    - dist/                 # Common distribution directory
    - *.egg-info/           # Python packaging metadata

# --- CONTEXT: High-level information about the project ---
CONTEXT:
  - project_description: |
      Python project, potentially a Flask web service/API or utility scripts, interacting with Google Cloud Platform services using standard Google client libraries. Uses Taskfile for automating development tasks (linting, formatting, AI context generation, container management) and Docker for containerization and deployment. Development primarily occurs in Project IDX.
  - tech_stack: |
      - Python 3 (Flask, google-auth, google-api-python-client, requests, etc.)
      - Google Cloud Platform (GCP): Likely uses services addressable by included libraries (e.g., Auth, potentially Compute, Storage, APIs). Specific services depend on implementation.
      - Docker (for containerization)
      - Taskfile (Task Runner)
      - Git
      - Project IDX (Development Environment)
      - Nix (Optional, via .idx/dev.nix for environment setup)
      - JSON / YAML (Common configuration formats)
      - Shell (Bash, common utils: git, python, docker, task, gcloud, jq)
  - architecture_overview: |
      - `scripts/` or `app/`: Expected location for Python source code.
      - `templates/`: Contains templates (e.g., HTML for Flask, config files).
      - `requirements.txt`: Defines Python dependencies.
      - `requirements-dev.txt`: (Optional) Defines development dependencies (e.g., linters, formatters).
      - `Dockerfile`: Defines the container image build process.
      - `Taskfile.yaml`: Central definition for project tasks (lint, format, build, push, ai context). Relies on tools like 'docker', 'git', 'python', potentially 'black'/'flake8'.
      - `.env`: Contains environment variables, notably `REGISTRY_PATH`, `IMAGE_NAME`, `IMAGE_TAG` for Docker tasks (sensitive, gitignored).
      - `README.md`: Should contain project setup, configuration, and usage instructions.
      - `.gitignore`: Specifies intentionally untracked files (secrets, venv, cache, etc.).
      - `.idx/`: Project IDX configuration files (`dev.nix`, `airules.md`).
      - `.venv/`: Local Python virtual environment (gitignored).
  - key_patterns: |
      - **Python:** Uses libraries from `requirements.txt`. Likely uses `google-auth` for authentication (ADC preferred). Flask conventions if it's a web app. Logging (`logging` module) preferred over `print`. Type hints (`typing`) encouraged. Error handling via try/except.
      - **Taskfile:** Defines tasks with `cmds`, `vars`, `preconditions`, `desc`. Uses variables from `.env` (`dotenv: [".env"]`). Wraps common command-line tools (`docker`, `python`, `git`, linters). `ai` task generates detailed context.
      - **Docker:** `Dockerfile` specifies base image, dependencies, code copying, entrypoint/cmd. `Taskfile.yaml` orchestrates `docker build`, `docker tag`, `docker push` using variables from `.env`. Image naming: `REGISTRY_PATH/IMAGE_NAME:TAG`.
      - **Configuration:** Primary runtime configuration expected via environment variables (potentially loaded from `.env` locally or set in deployment environment). Container build config in `.env`.
      - **Secrets:** Avoid hardcoding secrets in code. Use environment variables or potentially GCP Secret Manager. `.env` file is gitignored and used for local secrets/config.
      - **Authentication:** Application Default Credentials (ADC) is the preferred method for GCP authentication within IDX and deployed GCP environments.
  - security_notes: |
      - Critical: Avoid committing secrets (API keys, passwords, sensitive config) to Git. Use `.env` (gitignored) for local development or inject secrets via environment variables/Secret Manager in production.
      - IAM: If GCP service accounts are used, follow the Principle of Least Privilege.
      - Container Security: Ensure the `Dockerfile` uses trusted base images and minimizes included tools/data. Consider vulnerability scanning for built images.
      - The `.env` file is sensitive and MUST be included in `.gitignore`.
      - Be cautious asking the AI to generate code that *handles* secrets; ensure it follows best practices (e.g., reading from env vars, not hardcoding).
  - deployment_workflow_summary: |
      General workflow likely involves:
      1. Local Setup: Clone repo, ensure tools (Python, Docker, Task, potentially Nix pkgs) are available. Create/populate `.env`. Install Python dependencies (`pip install -r requirements.txt`).
      2. Development: Write/modify Python code (in `scripts/` or `app/`), update `Dockerfile` if needed, update `requirements.txt`.
      3. Linting/Formatting: Run `task lint:py` and `task format:py` (after installing `flake8`/`black`).
      4. Container Build: Run `task build` or `task build TAG=your-tag`.
      5. Authentication: Ensure Docker is authenticated to the target registry (e.g., `gcloud auth configure-docker REGISTRY_HOSTNAME`).
      6. Container Push: Run `task push` or `task push PUSH_TAG=your-tag`.
      7. Combined Build & Push: Run `task build-push` or `task build-push TAG=your-tag`.
      8. Deployment: Deploy the pushed container image to a GCP service (e.g., Cloud Run, GKE) or other container platform (details likely outside this project's scope but are the end goal).
      **Refer to `README.md` for specific setup and deployment steps.**

# --- RULE: Define specific instructions or constraints for the AI ---
RULE:
  - "**General:**"
  - "  - Explain the *purpose* and *reasoning* behind suggested code changes (Python, Dockerfile, Taskfile)."
  - "  - If asked to perform a task doable via `Taskfile.yaml` (like building/pushing containers, linting, formatting, generating AI context), suggest using the `task` command first (e.g., `task build`, `task lint:py`, `task ai`)."
  - "  - When adding/modifying significant functionality or configuration, suggest updating the `README.md`."
  - "  - Focus comments in code on the *why* (design decisions, non-obvious logic) rather than the *what* (unless complex) or *history*."
  - "  - Be aware that Python code is likely intended to run within a Docker container eventually."

  - "**Python Specific:**"
  - "  - Prioritize generating correct and idiomatic Python 3.11+ code."
  - "  - Adhere strictly to PEP 8 style guidelines. Suggest running `black` (via `task format:py` if configured) for formatting."
  - "  - Use libraries specified in `requirements.txt`. If suggesting new libraries, recommend adding them to `requirements.txt`."
  - "  - Prefer the `logging` module over `print()` for application output and errors."
  - "  - Use type hints (`typing` module) for function signatures and key variables."
  - "  - Include reasonable error handling (try/except blocks, checking return values)."
  - "  - Assume authentication uses Application Default Credentials (ADC) available in the IDX environment or the target GCP runtime. Do not suggest manual credential file handling unless specifically requested for a valid reason."
  - "  - Recommend running a linter (e.g., `flake8` via `task lint:py` if configured) after suggesting Python changes."

  - "**Docker Specific:**"
  - "  - Generate `Dockerfile` instructions following best practices (e.g., use specific base image versions, minimize layers, use multi-stage builds if appropriate, run as non-root user)."
  - "  - Ensure `Dockerfile` correctly installs dependencies from `requirements.txt` and copies necessary application code."
  - "  - When discussing building/tagging/pushing images, refer to the `Taskfile.yaml` tasks (`build`, `tag`, `push`, `build-push`) and the variables defined in `.env` (`REGISTRY_PATH`, `IMAGE_NAME`, `IMAGE_TAG`)."

  - "**Taskfile Specific:**"
  - "  - When modifying `Taskfile.yaml`, maintain the existing structure and variable usage patterns."
  - "  - Ensure preconditions accurately reflect task requirements."
  - "  - Use clear `summary` and `desc` fields for tasks."

  - "**Security:**"
  - "  - Adhere strictly to security best practices: NEVER suggest hardcoding secrets (API keys, passwords, etc.) in code, Dockerfiles, or Taskfiles."
  - "  - For configuration or secrets, recommend using environment variables (potentially sourced from `.env` locally, or injected in the deployment environment) or GCP Secret Manager."
  - "  - Do not suggest adding sensitive default values directly into committed code or configuration files."
  - "  - When suggesting IAM changes (if applicable, e.g., for service accounts used by the application), apply the Principle of Least Privilege and explain the permissions."
  - "  - Remember the `.env` file is sensitive and should not be committed."

  - "**Collaboration & Workflow:**"
  - "  - Describe the goal of requested changes clearly in the prompt."
  - "  - If suggesting significant code changes spanning multiple files, provide the full updated file(s) or clear instructions."
  - "  - If suggesting small, localized changes, provide the relevant snippet and clearly state the filename and function/context."
  - "  - Refer to the `Taskfile.yaml` for common workflow automation steps."
  - "  - Refer to the `README.md` for detailed user setup and deployment steps."