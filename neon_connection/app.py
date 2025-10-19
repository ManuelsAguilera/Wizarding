from flask import Flask, request, jsonify
import psycopg2
from datetime import datetime

app = Flask(__name__)

conn = psycopg2.connect(
    dbname="neondb",
    user="neondb_owner",
    password="npg_0gXxbED8fWGK",
    host="ep-curly-violet-ad2wouwu-pooler.c-2.us-east-1.aws.neon.tech",
    sslmode="require"
)

@app.route('/save', methods=['POST'])
def save_player_data():
    data = request.get_json(force=True)
    print("JSON recibido:", data)

    if not data:
        return jsonify({"error": "JSON inválido"}), 400

    cur = conn.cursor()

    for email, player_data in data.items():
        # Validacion minima
        if "info" not in player_data:
            continue

        info = player_data["info"]
        levels = player_data.get("levels", {})
        json_date = datetime.now().date().isoformat()

        # Insertar o actualizar jugador
        cur.execute("""
            INSERT INTO player (name, mail, age)
            VALUES (%s, %s, %s)
            ON CONFLICT (mail) DO UPDATE
            SET name = EXCLUDED.name,
                age = EXCLUDED.age
            RETURNING id
        """, (info["name"], email, int(info.get("age",0))))
        user_id = cur.fetchone()[0]

        # Insertar niveles
        for level_id, level_data in levels.items():
            # Insertar nivel si no existe
            cur.execute("""
                INSERT INTO level (id, name)
                VALUES (%s, %s)
                ON CONFLICT (id) DO NOTHING
            """, (level_id, level_id))

            # Insertar relacion jugador-nivel
            cur.execute("""
                INSERT INTO player_level (user_id, level_id, completion_date, movements, time, json_date)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (user_id, level_id)
                DO UPDATE SET completion_date = EXCLUDED.completion_date,
                              movements = EXCLUDED.movements,
                              time = EXCLUDED.time,
                              json_date = EXCLUDED.json_date
            """, (
                user_id,
                level_id,
                level_data.get("completion_date"),
                int(level_data.get("moves",0)),
                float(level_data.get("time",0)),
                json_date
            ))

    conn.commit()
    cur.close()
    return jsonify({"status": "ok", "message": "Datos guardados exitosamente."})


# Endpoint para cargar un jugador por email
@app.route('/load/<email>', methods=['GET'])
def load_player_data(email):
    cur = conn.cursor()

    # Obtener datos del jugador
    cur.execute("SELECT id, name, age FROM player WHERE mail = %s", (email,))
    player = cur.fetchone()
    if not player:
        cur.close()
        return jsonify({"error": "Jugador no encontrado"}), 404

    user_id, name, age = player

    # Obtener niveles asociados
    cur.execute("""
        SELECT level_id, completion_date, movements, time, json_date
        FROM player_level
        WHERE user_id = %s
    """, (user_id,))
    rows = cur.fetchall()
    cur.close()

    levels = {}
    for r in rows:
        levels[r[0]] = {
            "id": r[0],
            "completion_date": r[1],
            "moves": r[2],
            "time": r[3],
            "json_date": r[4]
        }

    return jsonify({
        "email": email,
        "info": {"name": name, "age": age},
        "levels": levels
    })


if __name__ == "__main__":
    print("Servidor backend iniciado en http://127.0.0.1:5000")
    app.run(host="0.0.0.0", port=5000)
