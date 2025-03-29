import os
import json
from flask import Flask, request, render_template, redirect, session
from google_auth_oauthlib.flow import Flow
import google.oauth2.credentials
import googleapiclient.discovery

print(os.environ.get("ALLOW_INSECURE_TRANSPORT"))

if os.environ.get("ALLOW_INSECURE_TRANSPORT") == "1":
    os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"
    print(
        "WARNING: OAUTHLIB_INSECURE_TRANSPORT is enabled.  For local development only!"
    )

app = Flask(__name__)
app.secret_key = os.environ.get(
    "FLASK_SECRET_KEY", os.urandom(24)
)  # From env or random

# --- Configuration (Load from environment variables) ---
CLIENT_CONFIG = {
    "web": {
        "client_id": os.environ.get("GOOGLE_CLIENT_ID"),
        "client_secret": os.environ.get("GOOGLE_CLIENT_SECRET"),
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "redirect_uris": [os.environ.get("REDIRECT_URI")],
        "project_id": os.environ.get("GOOGLE_PROJECT_ID"),
    }
}
# --- End Configuration ---


@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        # Get selected scopes directly as a list
        scopes = request.form.getlist("scopes")  # Use getlist()
        session["scopes"] = scopes

        redirect_uri = os.environ.get("REDIRECT_URI")

        CLIENT_CONFIG["web"]["redirect_uris"] = [redirect_uri]
        session["redirect_uri"] = redirect_uri

        # Create flow
        flow = Flow.from_client_config(
            CLIENT_CONFIG, scopes=scopes, redirect_uri=redirect_uri
        )
        auth_url, state = flow.authorization_url(
            access_type="offline", prompt="consent"
        )
        session["state"] = state

        return redirect(auth_url)

    return render_template("index.html")


@app.route("/callback")
def callback():
    # Retrieve data stored in the session
    state = session["state"]
    scopes = session["scopes"]
    redirect_uri = session["redirect_uri"]

    # update client config with the latest redirect_uri
    CLIENT_CONFIG["web"]["redirect_uris"] = [redirect_uri]
    flow = Flow.from_client_config(
        CLIENT_CONFIG, scopes=scopes, state=state, redirect_uri=redirect_uri
    )
    # Use the authorization server's response to fetch the OAuth 2.0 tokens.
    authorization_response = request.url
    flow.fetch_token(authorization_response=authorization_response)

    # Store the credentials in the session.
    credentials = flow.credentials
    token_data = {
        "token": credentials.token,
        "refresh_token": credentials.refresh_token,
        "token_uri": credentials.token_uri,
        "client_id": credentials.client_id,
        "client_secret": credentials.client_secret,
        "scopes": credentials.scopes,
        "expiry": credentials.expiry.isoformat() if credentials.expiry else None,
    }

    return render_template("token.html", token_data=token_data)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)), debug=False)
