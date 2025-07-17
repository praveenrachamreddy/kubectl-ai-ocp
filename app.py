import os
import subprocess
from flask import Flask, request, jsonify

app = Flask(__name__)

# Load OpenAI key from env var (set via secret in OpenShift)
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

@app.route("/ask", methods=["POST"])
def ask():
    data = request.get_json()
    question = data.get("question") if data else None

    if not question:
        return jsonify({"error": "Missing 'question' in request"}), 400
    if not OPENAI_API_KEY:
        return jsonify({"error": "OPENAI_API_KEY not set in environment"}), 500

    try:
        env = os.environ.copy()
        env["OPENAI_API_KEY"] = OPENAI_API_KEY

        # Run kubectl-ai with --run so it both generates and executes
        result = subprocess.run(
            ["kubectl-ai", "--llm-provider=openai", "--model=gpt-4.1", "--run", question],
            capture_output=True,
            text=True,
            env=env,
            timeout=30
        )

        return jsonify({
            "question": question,
            "output": result.stdout.strip(),
            "error": result.stderr.strip()
        }), 200

    except subprocess.TimeoutExpired:
        return jsonify({"error": "Command timed out"}), 504
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/", methods=["GET"])
def health():
    return "kubectl-ai API is running", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
