from flask import Flask, request, render_template
import logging
import os
import cryptography

app = Flask(__name__)

os.makedirs("logs", exist_ok=True)

logging.basicConfig(
    filename="logs/attacks.log",
    level=logging.INFO,
    format="%(asctime)s %(message)s"
)

@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":

        username = request.form.get("username")
        password = request.form.get("password")

        logging.info(
            f"IP={request.remote_addr} "
            f"USER={username} "
            f"PASS={password} "
            f"UA={request.headers.get('User-Agent')}"
        )

    return render_template("login.html")

@app.route("/dashboard", methods=["GET", "POST"])
def dashboard():
    if request.method == "POST":

        logging.info(
            f"IP={request.remote_addr} "
            f"UA={request.headers.get('User-Agent')}"
        )

    return render_template("dashboard.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=443, ssl_context='adhoc')
