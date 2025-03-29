# Python Flask Google OAuth Example

This project provides a basic Python Flask web application demonstrating Google OAuth integration. It is containerized using Docker and includes Taskfile definitions for common development and build workflows. The project is configured for easy setup and development using Project IDX.

## Using Project IDX (Recommended)

This repository is configured for use with [Project IDX](https://idx.google.com), Google's cloud-based development environment. Using IDX simplifies setup and ensures a consistent development environment.

**Click the button below to open this project directly in Project IDX (Replace URL if applicable):**

<!-- TODO: Replace with your actual GitHub repo URL if you want the button to work -->
<a href="https://idx.google.com/import?url=YOUR_GITHUB_REPO_URL_HERE">
  <picture>
    <source
      media="(prefers-color-scheme: dark)"
      srcset="https://cdn.idx.dev/btn/open_dark_20.svg">
    <source
      media="(prefers-color-scheme: light)"
      srcset="https://cdn.idx.dev/btn/open_light_20.svg">
    <img
      height="20"
      alt="Open in IDX"
      src="https://cdn.idx.dev/btn/open_purple_20.svg">
  </picture>
</a>

**Benefits of using IDX for this project:**

*   **Pre-configured Environment:** The `.idx/dev.nix` file ensures your workspace includes necessary tools (Python 3.11, gcloud CLI, Docker, Taskfile, black, flake8, git, etc.).
*   **Automated Setup:** The `onCreate` hook in `.idx/dev.nix` automatically creates a Python virtual environment (`.venv/`) and installs dependencies from `requirements.txt` when the workspace is first created.
*   **Consistency:** All contributors can work within the same environment setup.
*   **Cloud-Based:** Develop from anywhere without needing extensive local installations (beyond a web browser).
*   **AI Integration:** Leverage IDX's built-in AI features, using the context provided in `.idx/airules.md`.

If using IDX, you can often skip manual tool installation steps. You **still need to authenticate `gcloud`** within the IDX workspace terminal (see Setup step 1) and **configure the `.env` file** (Setup step 2).

## Prerequisites

Before starting (especially if **not** using Project IDX, or if IDX environment needs supplementing), ensure you have the following tools installed and configured:

1.  **Google Cloud SDK (`gcloud`):** [Installation Guide](https://cloud.google.com/sdk/docs/install)
    *   Ensure you are authenticated (run these within your terminal or the IDX terminal):
        ```bash
        gcloud auth login
        gcloud auth application-default login
        ```
2.  **Docker:** [Installation Guide](https://docs.docker.com/engine/install/) (Needed to build and run the container image).
3.  **Python 3:** (Version 3.11.x recommended, see `.idx/dev.nix`).
4.  **Git:** For cloning the repository.
5.  **(Optional but Recommended) Taskfile:** [Installation Guide](https://taskfile.dev/installation/) (To use the helper tasks defined in `Taskfile.yaml`).

## Setup and Configuration

Follow these steps to configure the project before development or deployment. **Run commands from the project root directory unless otherwise specified.**

**1. Configure GCP Project (Optional but Recommended):**

Set your active `gcloud` project if you plan to push images to Google Artifact Registry or deploy to GCP (run within your terminal or the IDX terminal):
```bash
gcloud config set project <YOUR_GCP_PROJECT_ID>
```
*(Replace `<YOUR_GCP_PROJECT_ID>` with the ID of the project where you might deploy or store images).*

**2. Create `.env` Configuration File:**

This file provides configuration for the Docker container build/push tasks. It is **ignored by Git** and should not be committed.

*   Create a file named `.env` in the project root:
    ```bash
    # Example .env content
    # Replace with your actual registry path (e.g., Google Artifact Registry)
    REGISTRY_PATH=us-central1-docker.pkg.dev/your-gcp-project-id/your-repo-name
    # Choose a name for your container image
    IMAGE_NAME=my-flask-oauth-app
    # Default tag to use (optional, 'latest' is the Taskfile default)
    IMAGE_TAG=latest

    # Add any other environment variables needed by app.py at runtime here
    # Example (replace with actual values required by app.py):
    # GOOGLE_CLIENT_ID="your-client-id.apps.googleusercontent.com"
    # GOOGLE_CLIENT_SECRET="your-client-secret"
    # FLASK_SECRET_KEY="a-very-secret-key-for-sessions"
    # BASE_URL="http://localhost:8080" # Or your deployed URL
    ```
*   **Important:** Replace placeholders with your actual values. Consult `app.py` to see which runtime environment variables it requires.

**3. Setup Python Virtual Environment (Handled by IDX `onCreate`):**

*   **If using IDX:** The `.idx/dev.nix` configuration automatically creates a `.venv/` directory and runs `pip install -r requirements.txt` within it when the workspace is first created.
*   **If NOT using IDX (or after resetting):**
    1.  Create the virtual environment: `python3 -m venv .venv`
    2.  Activate it: `source .venv/bin/activate`
    3.  Install dependencies: `pip install -r requirements.txt`

**4. Activate Virtual Environment (Terminal Usage):**

To run `python`, `flask`, or `pip` commands directly in your terminal session, you **must activate** the virtual environment first:
```bash
source .venv/bin/activate
```
*(VS Code/IDX often detect the `.venv` automatically for running/debugging).*

## Development and Execution Workflow

**1. Run Locally (Flask Development Server):**

1.  Ensure `.env` is created and populated with runtime variables needed by `app.py`.
2.  Activate the virtual environment: `source .venv/bin/activate`
3.  Run the Flask development server (command might vary based on `app.py`):
    ```bash
    # Common ways to run Flask apps:
    export FLASK_APP=app.py
    export FLASK_DEBUG=1 # Enables debug mode (optional)
    flask run --port=8080
    # Or, if app.py uses if __name__ == "__main__": app.run(...)
    # python app.py
    ```
4.  Access the application in your browser (usually `http://localhost:8080` or `http://127.0.0.1:8080`).

**2. Lint and Format Code:**

Use Taskfile commands (from project root):
```bash
# Check code style (requires flake8 installed via Nix)
task lint:py

# Format code (requires black installed via Nix)
task format:py
```

**3. Build Container Image:**

Ensure `.env` contains `REGISTRY_PATH` and `IMAGE_NAME`.
```bash
# Build image with default tag (from .env or 'latest')
task build

# Build image with a specific tag
task build TAG=v1.0.0
```

**4. Push Container Image:**

Ensure you are authenticated to your container registry (e.g., for Google Artifact Registry):
```bash
# Example authentication command (replace placeholders)
gcloud auth configure-docker us-central1-docker.pkg.dev
```
Then push the image using Taskfile:
```bash
# Push the default tag (from .env or 'latest')
task push

# Push a specific tag
task push PUSH_TAG=v1.0.0
```

**5. Build and Push Combined:**

```bash
# Build and push default tag
task build-push

# Build and push specific tag
task build-push TAG=v1.0.0
```

**6. Deploy to Cloud (Conceptual):**

Deploy the pushed container image to a cloud service like Google Cloud Run or Google Kubernetes Engine. Deployment steps vary depending on the target platform and are outside the scope of this README. Example for Cloud Run:
```bash
# Example (replace placeholders and add necessary flags like --env-vars-file, --region, --allow-unauthenticated)
# gcloud run deploy <SERVICE_NAME> \
#   --image=<REGISTRY_PATH>/<IMAGE_NAME>:<TAG> \
#   --platform=managed \
#   --project=<YOUR_GCP_PROJECT_ID>
```

## Taskfile Usage

Use Taskfile from the project root directory for common workflows:

*   `task format:py`: Format Python code using `black` (targets `.`).
*   `task lint:py`: Lint Python code using `flake8` (targets `.`).
*   `task ai`: Format code and generate AI context file (`ai_context.txt`).
*   `task build`: Build the Docker image using `.env` variables. Optionally pass `TAG=...`.
*   `task tag`: Apply an additional tag to a local image. Requires `NEW_TAG=...` and optionally `SOURCE_TAG=...`.
*   `task push`: Push a specified image tag to the registry using `.env` variables. Optionally pass `PUSH_TAG=...`.
*   `task build-push`: Build and then Push the image. Optionally pass `TAG=...`.

---

## Future Improvements / TODO

*   [ ] **App Configuration:** Improve how `app.py` reads configuration (e.g., use Flask-Config, decouple from only `.env`).
*   [ ] **Error Handling:** Enhance error handling and user feedback within `app.py`.
*   [ ] **Logging:** Implement proper logging in `app.py` instead of just `print` statements.
*   [ ] **Testing:** Add unit tests (`pytest`) for `app.py` logic. Add integration tests.
*   [ ] **Dockerfile:** Optimize `Dockerfile` (multi-stage build, non-root user, security best practices).
*   [ ] **Dependencies:** Pin dependencies more strictly using `pip-tools` (`requirements.in` -> `requirements.txt`).
*   [ ] **Taskfile:** Add tasks for running tests, cleaning build artifacts.
*   [ ] **CI/CD:** Implement a pipeline (GitHub Actions, Cloud Build) for automated linting, testing, building, and potentially deploying.
*   [ ] **IDX Previews:** Configure `idx.previews` in `dev.nix` to easily preview the running Flask app within IDX.
*   [ ] **Documentation:** Add more details about the specific OAuth flow implemented in `app.py`. Add an architecture diagram if applicable.
*   [ ] **Secrets Management:** Review how sensitive information (like Flask secret key, OAuth secrets if not in `.env`) is handled. Consider GCP Secret Manager for deployed instances.

---