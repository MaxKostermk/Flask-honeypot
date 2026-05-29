from flask import Flask, request, render_template, redirect
from datetime import datetime, timezone
import json
import os

app = Flask(__name__)

LOG_FILE = "/var/log/honeypot/fakepanel.jsonl"

def write_log(event):
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    event["timestamp"] = datetime.now(timezone.utc).isoformat()
    event["source_ip"] = request.headers.get("X-Forwarded-For", request.remote_addr)
    event["user_agent"] = request.headers.get("User-Agent", "")
    event["path"] = request.path
    event["method"] = request.method

    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(event) + "\n")


@app.route("/", methods=["GET"])
def index():
    write_log({"event": "page_view"})
    return redirect("/login")

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        write_log({
            "event": "login_attempt",
            "username": request.form.get("username", ""),
            "password": request.form.get("password", ""),
            "headers": dict(request.headers),
            "form": request.form.to_dict()
        })
        return render_template("login.html", error="Invalid username or password")

    write_log({"event": "login_page"})
    return render_template("login.html", error=None)

