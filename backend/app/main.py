import os
from flask import Flask, jsonify
from flask_cors import CORS
from dotenv import load_dotenv


def create_app() -> Flask:
    load_dotenv()  # load .env from project root

    app = Flask(__name__)
    CORS(app)

    # Basic config from env
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret')
    app.config['MYSQL_HOST'] = os.getenv('MYSQL_HOST', '127.0.0.1')
    app.config['MYSQL_PORT'] = int(os.getenv('MYSQL_PORT', '3306'))
    app.config['MYSQL_USER'] = os.getenv('MYSQL_USER', 'root')
    app.config['MYSQL_PASSWORD'] = os.getenv('MYSQL_PASSWORD', '')
    app.config['MYSQL_DB'] = os.getenv('MYSQL_DB', 'puzzlemaster')

    @app.get('/health')
    def health():
        return jsonify({"ok": True})

    return app


app = create_app()


