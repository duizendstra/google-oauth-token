# Google OAuth 2.0 Token Fetcher (Simplified)

This app gets a Google OAuth 2.0 token and shows it.  It runs on Google Cloud Run.
Open the project in Project IDX: https://idx.google.com/import?url=https://github.com/duizendstra/google-oauth-token

## Setup

1.  **Google Cloud Project:**  Have a GCP project and the `gcloud` SDK set up.
2.  **OAuth Client ID:**
    *   Go to [https://console.cloud.google.com/](https://console.cloud.google.com/) -> APIs & Services -> Credentials.
    *   Create an OAuth client ID (Web application).
    *   Leave "Authorized JavaScript origins" blank.
    *   Set "Authorized Redirect URIs" to `http://localhost:8080/callback` *for now*. You'll change this *after* deploying.
    *   Get your Client ID and Secret.
3.  **Files:** Get the project files (`app.py`, `requirements.txt`, `Dockerfile`, `templates/index_env.html`, `templates/token.html`).

4.  **`.env.yaml`:** Create a `.env.yaml` file:

    ```yaml
    GOOGLE_CLIENT_ID: "{YOUR_GOOGLE_CLIENT_ID}"
    GOOGLE_CLIENT_SECRET: "{YOUR_GOOGLE_CLIENT_SECRET}"
    GOOGLE_PROJECT_ID: "{YOUR_GOOGLE_PROJECT_ID}"
    FLASK_SECRET_KEY: "{YOUR_FLASK_SECRET_KEY}"
    REDIRECT_URI: "{YOUR_CLOUD_RUN_URL_URLENCODED}/callback" # Change AFTER deploy!
    ALLOW_INSECURE_TRANSPORT: "0"   # "1" ONLY for http://localhost
    ```

    *   Fill in the placeholders (including a strong `FLASK_SECRET_KEY`).
    *   **Important:** Don't commit `.env.yaml`.
    *   **`REDIRECT_URI`:**  You *must* update this *after* deploying.  It needs your Cloud Run URL (with `/callback`), *URL-encoded*.  Use a tool like [https://www.urlencoder.org/](https://www.urlencoder.org/).  Example:
        *   Cloud Run URL: `https://my-app.run.app/callback`
        *   Encoded: `https%3A%2F%2Fmy-app.run.app%2Fcallback`

5. **Enable APIs & Define Scopes:**
    *   Go to the Google Cloud Console -> APIs & Services -> Library.
    *   Search for and **enable** the APIs you need scopes for (e.g., "Google Workspace License Manager API").
    *   **Verify** that the scope is available as a checkbox option on the application's main page (`index.html`). If not, it needs to be added to the `templates/index.html` file. For the Google License Manager, the scope is:
        *   `https://www.googleapis.com/auth/apps.licensing`

## Deploy

1.  Go to your project directory: `cd {YOUR_PROJECT_DIRECTORY}`
2.  Deploy to Cloud Run:

    ```bash
    gcloud run deploy token-fetcher \
        --source . \
        --platform managed \
        --allow-unauthenticated \
        --region {YOUR_REGION} \
        --env-vars-file .env.yaml
    ```

3.  **Get URL:** `gcloud` will show you the service URL.

4.  **Update Redirect URI (CRITICAL!):**
    *   **`.env.yaml`:**  Update `REDIRECT_URI` with your *URL-encoded* Cloud Run URL + `/callback`.
    *   **Google Cloud Console:**  Add the *same* URL-encoded URL to "Authorized Redirect URIs" for your OAuth client ID.

5.  **Redeploy:**  Run the `gcloud run deploy` command *again* (same command as step 2).

## Use

1.  Open your Cloud Run URL.
2.  Select scopes, click "Authorize".
3.  Log in to Google.
4.  See the token.

## Security

*   Don't put secrets in your code. Use `.env.yaml`.
*   This app shows the refresh token – don't do that in a real app!