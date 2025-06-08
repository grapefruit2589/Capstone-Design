from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL
import bcrypt

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# MySQL 설정
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '0000'
app.config['MYSQL_DB'] = 'capston_db'

mysql = MySQL(app)

# 긴급 호출 큐
emergency_queue = []

# 서버 상태 확인
@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "pong"}), 200

# 회원가입 처리 함수
def handle_signup(table, columns, input_keys, field_labels):
    try:
        data = request.json or {}
        print(f"[{table}] 받은 데이터:", data)

        values = [data.get(k, '').strip() for k in input_keys]
        if not all(values):
            return jsonify({"error": "입력값이 비어 있습니다."}), 400

        cur = mysql.connection.cursor()
        check_query = f"SELECT 1 FROM {table} WHERE {columns[1]} = %s OR {columns[2]} = %s"
        cur.execute(check_query, (values[1], values[2]))
        if cur.fetchone():
            cur.close()
            return jsonify({"error": "이미 존재하는 이메일 또는 전화번호입니다."}), 409

        hashed_pw = bcrypt.hashpw(values[3].encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        insert_query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES (%s, %s, %s, %s)"
        cur.execute(insert_query, (values[0], values[1], values[2], hashed_pw))
        mysql.connection.commit()
        cur.close()

        print(f"[{table}] DB 저장 성공")
        return jsonify({"message": f"{field_labels} 회원가입 성공!"}), 200

    except Exception as e:
        print(f"[{table}] 에러:", e)
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500

# 노인 회원가입
@app.route('/member/signup', methods=['POST'])
def member_signup():
    return handle_signup(
        table='members',
        columns=['mem_name', 'mem_email', 'mem_tel', 'mem_pw'],
        input_keys=['mem_name', 'mem_email', 'mem_tel', 'mem_pw'],
        field_labels="노인"
    )

# 요양보호사 회원가입
@app.route('/nurse/signup', methods=['POST'])
def nurse_signup():
    return handle_signup(
        table='nurses',
        columns=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        input_keys=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        field_labels="요양보호사"
    )

# caregiver/signup → nurse/signup으로 매핑
@app.route('/caregiver/signup', methods=['POST'])
def caregiver_signup():
    data = request.json or {}
    mapped_data = {
        "nurse_name": data.get("caregiver_name", "").strip(),
        "nurse_email": data.get("caregiver_email", "").strip(),
        "nurse_tel": data.get("caregiver_tel", "").strip(),
        "nurse_pw": data.get("caregiver_pw", "").strip(),
    }
    request.json.clear()
    request.json.update(mapped_data)

    return handle_signup(
        table='nurses',
        columns=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        input_keys=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        field_labels="요양보호사"
    )

# 로그인 처리
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json or {}
        email = data.get('email', '').strip()
        pw = data.get('password', '').strip()
        role = data.get('role', '').strip()

        if not email or not pw or not role:
            return jsonify({"success": False, "error": "이메일, 비밀번호, 역할을 모두 입력하세요."}), 400

        cur = mysql.connection.cursor()

        if role == 'member':
            cur.execute("SELECT mem_name, mem_pw FROM members WHERE mem_email = %s", (email,))
            row = cur.fetchone()
            if not row:
                cur.close()
                return jsonify({"success": False, "error": "노인 계정이 존재하지 않습니다."}), 404

            stored_name, stored_hashed_pw = row
            if bcrypt.checkpw(pw.encode('utf-8'), stored_hashed_pw.encode('utf-8')):
                cur.close()
                return jsonify({"success": True, "role": "member", "name": stored_name}), 200
            else:
                cur.close()
                return jsonify({"success": False, "error": "비밀번호가 올바르지 않습니다."}), 401

        elif role == 'nurse':
            cur.execute("SELECT nurse_name, nurse_pw FROM nurses WHERE nurse_email = %s", (email,))
            row = cur.fetchone()
            if not row:
                cur.close()
                return jsonify({"success": False, "error": "요양보호사 계정이 존재하지 않습니다."}), 404

            stored_name, stored_hashed_pw = row
            if bcrypt.checkpw(pw.encode('utf-8'), stored_hashed_pw.encode('utf-8')):
                cur.close()
                return jsonify({"success": True, "role": "nurse", "name": stored_name}), 200
            else:
                cur.close()
                return jsonify({"success": False, "error": "비밀번호가 올바르지 않습니다."}), 401

        else:
            cur.close()
            return jsonify({"success": False, "error": "유효하지 않은 사용자 역할입니다."}), 400

    except Exception as e:
        print("로그인 에러:", e)
        return jsonify({"success": False, "error": str(e)}), 500

# 긴급 호출 발생 (노인 측)
@app.route('/emergency', methods=['POST'])
def emergency():
    try:
        data = request.json or {}
        mem_name = data.get("mem_name", "").strip()

        if not mem_name:
            return jsonify({"error": "mem_name 키에 노인 이름을 담아주세요."}), 400

        cur = mysql.connection.cursor()
        cur.execute("SELECT mem_id FROM members WHERE mem_name = %s", (mem_name,))
        row = cur.fetchone()
        if not row:
            cur.close()
            return jsonify({"error": f"{mem_name} 어르신이 존재하지 않습니다."}), 404

        mem_id = row[0]
        cur.execute("SELECT nurse_name FROM nurses WHERE nurse_id = %s", (mem_id,))
        nurse_row = cur.fetchone()

        if nurse_row:
            nurse_name = nurse_row[0]
        else:
            cur.execute("SELECT nurse_name FROM nurses ORDER BY nurse_id LIMIT 1")
            fallback = cur.fetchone()
            if fallback:
                nurse_name = fallback[0]
            else:
                cur.close()
                return jsonify({"message": "현재 담당 요양보호사가 없습니다. 112에 연결 중입니다."}), 200

        cur.close()

        # 긴급 호출 큐에 이름 추가
        emergency_queue.append(mem_name)

        return jsonify({"nurse_name": nurse_name}), 200

    except Exception as e:
        print("긴급 호출 에러:", e)
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500

# 요양보호사 앱 → 긴급 호출 확인
@app.route('/emergency_queue', methods=['GET'])
def check_emergency_queue():
    if emergency_queue:
        mem_name = emergency_queue.pop(0)
        return jsonify({"mem_name": mem_name}), 200
    else:
        return jsonify({"message": "대기 중인 호출 없음"}), 204

# 서버 실행
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
