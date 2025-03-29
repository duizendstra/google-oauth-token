# .idx/dev.nix
# -----------------------------------------------------------------------------
# Nix configuration for this Project IDX workspace environment.
# Defines system packages, VS Code extensions, services, and setup scripts
# needed for developing the project.
#
# Learn more: https://developers.google.com/idx/guides/customize-idx-env
# Search for Nix packages: https://search.nixos.org/packages
# Search for VS Code extensions: https://open-vsx.org/
# -----------------------------------------------------------------------------
{ pkgs, ... }: {

  # -- Environment Channel ----------------------------------------------------
  # Specifies the nixpkgs channel to pull packages from. Using a stable
  # channel ensures better reproducibility.
  channel = "stable-24.05"; # Recommended for stability, check https://status.nixos.org/

  # -- System Packages --------------------------------------------------------
  # List of command-line tools and libraries available in the workspace terminal.
  packages = [
    # Core Development Environment
    pkgs.python3 # Python 3 interpreter (check version if specific needs exist)
    pkgs.python3Packages.flake8 # Python linter 
    pkgs.git # Version control system (essential for git operations)
    pkgs.go-task # Taskfile runner (to execute tasks defined in Taskfile.yaml)
    pkgs.python311Packages.pip

    # Python Tooling (for linting, formatting - used by Taskfile)
    pkgs.black # The uncompromising Python code formatter

    # Google Cloud SDK
    pkgs.google-cloud-sdk # gcloud CLI, gsutil, etc. (for interacting with GCP)

    # Common Utilities
    pkgs.jq # Command-line JSON processor (useful for scripts, checked by 'ai' task)
    pkgs.tree # Displays directory structures (used by 'ai' task)
    pkgs.patch # Applies patch files (standard utility)
  ];

  # -- Services ---------------------------------------------------------------
  # Enable background services within the workspace.
  services.docker.enable = true; # Enables the Docker daemon (required for container tasks)

  # -- Project IDX Configuration ----------------------------------------------
  # Settings specific to the Project IDX platform.
  idx = {

    # VS Code Extensions
    # Automatically installs these extensions in the workspace's VS Code instance.
    extensions = [
      # Python Language Support
      "ms-python.python" # Core Python features (intellisense, linting, formatting, etc.)
      "ms-python.debugpy" # Python debugger support

      # Python Formatting & Linting Integration
      "ms-python.black-formatter" # Integrates 'black' formatting into VS Code
      "ms-python.flake8" # Integrates 'flake8' linting into VS Code (shows errors in editor)

      # Container Development Support
      "ms-azuretools.vscode-docker" # Dockerfile syntax highlighting, Docker container management

      # Configuration File Support
      "redhat.vscode-yaml" # Enhanced editing support for YAML files (like Taskfile.yaml)
    ];

    # Workspace Lifecycle Hooks
    # Scripts that run at different stages of the workspace lifecycle.
    workspace = {

      # Runs ONCE when the workspace is first created or reset.
      onCreate = {
        # --- Setup Python Virtual Environment and Install Dependencies ---
        # This script ensures a clean, isolated Python environment for the project's
        # libraries, separate from the global Nix packages.
        setup-venv = ''
          echo "[onCreate] Starting Python virtual environment setup..."

          # 1. Verify python3 command is available from Nix packages
          if ! command -v python3 &> /dev/null; then
              echo "[onCreate] Error: python3 command not found. Cannot set up venv."
              exit 1 # Stop the script if Python isn't found
          fi

          # 2. Define the virtual environment directory name
          VENV_DIR=".venv" # Standard name, ensure it's in .gitignore

          # 3. Create the virtual environment if it doesn't exist
          if [ ! -d "$VENV_DIR" ]; then
            echo "[onCreate] Creating Python virtual environment in '$VENV_DIR'..."
            python3 -m venv "$VENV_DIR"
            # Check if venv creation was successful
            if [ $? -ne 0 ]; then
              echo "[onCreate] Error: Failed to create virtual environment."
              exit 1
            fi
            echo "[onCreate] Virtual environment created successfully."
          else
            echo "[onCreate] Virtual environment '$VENV_DIR' already exists. Skipping creation."
          fi

          # 4. Define the path to the pip executable within the virtual environment
          VENV_PIP="$VENV_DIR/bin/pip"

          # 5. Verify that pip exists within the created venv
          if [ ! -f "$VENV_PIP" ]; then
             echo "[onCreate] Error: pip executable not found at '$VENV_PIP'."
             exit 1
          fi
          echo "[onCreate] Using pip from virtual environment: $VENV_PIP"

          # 6. Install main dependencies (if requirements.txt exists)
          if [ -f requirements.txt ]; then
             echo "[onCreate] Found requirements.txt. Installing main dependencies into '$VENV_DIR'..."
             # Use the venv's pip to install packages into the venv
             "$VENV_PIP" install --no-cache-dir -r requirements.txt
             if [ $? -ne 0 ]; then
               # Log error but continue (might be acceptable in some scenarios)
               echo "[onCreate] Warning: Failed to install some dependencies from requirements.txt."
             else
               echo "[onCreate] Finished installing main dependencies."
             fi
          else
             echo "[onCreate] requirements.txt not found. Skipping main dependency installation."
          fi

          # 7. Install development dependencies (if requirements-dev.txt exists)
          #    (Commonly used for linters, formatters, testing tools if not managed by Nix)
          if [ -f requirements-dev.txt ]; then
             echo "[onCreate] Found requirements-dev.txt. Installing development dependencies into '$VENV_DIR'..."
             "$VENV_PIP" install --no-cache-dir -r requirements-dev.txt
             if [ $? -ne 0 ]; then
               echo "[onCreate] Warning: Failed to install some dependencies from requirements-dev.txt."
             else
                echo "[onCreate] Finished installing development dependencies."
             fi
          else
             echo "[onCreate] requirements-dev.txt not found. Skipping dev dependency installation."
          fi

          # 8. Final confirmation message
          echo "[onCreate] Python virtual environment setup process complete."
          # Reminder: Activation needed for terminal use (VS Code usually detects automatically)
          echo "[onCreate] To use the venv in the terminal, run: source $VENV_DIR/bin/activate"
        ''; # End of setup-venv script
      }; # End of onCreate

      # Runs EVERY TIME the workspace starts (including after creation/rebuilds).
      onStart = {
        # --- Startup Checks & Reminders ---
        # (Currently empty as requested, but structure remains for future use)
        # Example: Add reminders or quick status checks here if needed.
        # startup-info = ''
        #   echo "[onStart] Workspace starting..."
        #   # Add commands here, e.g., check gcloud auth, remind about venv
        # '';
      }; # End of onStart

    }; # End of workspace lifecycle hooks

    # Web Previews Configuration
    # Allows IDX to automatically expose web applications running in the workspace.
    previews = {
      enable = false; # Set to true and configure below if running a web server
      # config = [
      #   {
      #     id = "web"; label = "Web App"; port = 8080; command = ["python", "app.py"];
      #   }
      # ];
    }; # End of previews

  }; # End of idx configuration block
}
