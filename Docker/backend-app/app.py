"""
Backend Application
------------------
A simple Python app for demonstration purposes.
"""

from flask import Flask, jsonify
import os
import psycopg2
from psycopg2 import OperationalError

app = Flask(__name__)

def get_db_connection():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        database=os.environ.get("DB_NAME", "postgres"),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5
    )

@app.route('/health')
def health():
    return 'OK', 200

@app.route('/')
@app.route('/api')
def index():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            CREATE TABLE IF NOT EXISTS visits (
                id INTEGER PRIMARY KEY,
                count INTEGER NOT NULL DEFAULT 0
            );
        """)
        
        cur.execute("""
            INSERT INTO visits (id, count)
            VALUES (1, 1)
            ON CONFLICT (id) DO UPDATE SET count = visits.count + 1
            RETURNING count;
        """)
        
        visits = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({
            "message": "Welcome to Project2-Cs454 Terraform Backend!",
            "visits": visits,
            "status": "healthy"
        })
        
    except OperationalError as e:
        return jsonify({"error": "Database connection failed", "details": str(e)}), 503
    except Exception as e:
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)