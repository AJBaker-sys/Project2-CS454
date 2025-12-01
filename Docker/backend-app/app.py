"""
Backend Application
A simple Python app for demonstration purposes.
"""

from flask import Flask, jsonify
import os
import psycopg2
from psycopg2 import OperationalError

app = Flask(__name__)

def get_db_connection():
    # helper: open a DB connection using environment variables
    # raises OperationalError on connection problems
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        database=os.environ.get("DB_NAME", "postgres"),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5
    )

@app.route('/health')
def health():
    # simple health endpoint (used by container HEALTHCHECK)
    return 'OK', 200

@app.route('/')
@app.route('/api')
def index():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # ensure the visits table exists (id=1 will track visits)
        cur.execute("""
            CREATE TABLE IF NOT EXISTS visits (
                id INTEGER PRIMARY KEY,
                count INTEGER NOT NULL DEFAULT 0
            );
        """)
        
        # upsert a single row (id=1) to increment visit count
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
            "message": "Project2-Cs454 Terraform Backend Test!",
            "visits": visits,
            "status": "healthy"
        })
        
    except OperationalError as e:
        # database unreachable so return 503 so orchestrators know
        return jsonify({"error": "Database connection failed", "details": str(e)}), 503
    except Exception as e:
        # generic 500 for unexpected errors
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

if __name__ == '__main__':
    
    app.run(host='0.0.0.0', port=5000)