# ─────────────────────────────────────────────────────────────────────────────
# app.py (Flask 백엔드 전체 – “members 먼저 조회” 순서로 수정본)
# ─────────────────────────────────────────────────────────────────────────────

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL
import bcrypt

app = Flask(__name__)

# CORS 설정: 모든 Origin 허용
CORS(app, resources={r"/*": {"origins": "*"}})

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 MySQL 연결 설정
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '0000'
app.config['MYSQL_DB'] = 'capston_db'

mysql = MySQL(app)

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 서버 상태 체크용
@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "pong"}), 200

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 회원가입 공통 처리 함수 (변경 없음)
def handle_signup(table, columns, input_keys, field_labels):
    try:
        data = request.json
        print(f"[{table}] 받은 데이터:", data)

        # 필수 입력값 추출
        values = [data.get(k, '').strip() for k in input_keys]
        # 하나라도 비어 있으면
        if not all(values):
            return jsonify({"error": "입력값이 비어 있습니다."}), 400

        cur = mysql.connection.cursor()

        # 이메일 또는 전화번호 중복 체크
        # columns[1] = 이메일 컬럼명, columns[2] = 전화번호 컬럼명
        check_query = f"SELECT * FROM {table} WHERE {columns[1]} = %s OR {columns[2]} = %s"
        cur.execute(check_query, (values[1], values[2]))
        if cur.fetchone():
            return jsonify({"error": "이미 존재하는 이메일 또는 전화번호입니다."}), 409

        # 비밀번호 해싱
        hashed_pw = bcrypt.hashpw(values[3].encode('utf-8'), bcrypt.gensalt())

        # INSERT 쿼리 실행
        insert_query = f"""
            INSERT INTO {table} ({', '.join(columns)})
            VALUES (%s, %s, %s, %s)
        """
        cur.execute(insert_query, (values[0], values[1], values[2], hashed_pw.decode('utf-8')))
        mysql.connection.commit()
        cur.close()

        print(f"[{table}] DB 저장 성공")
        return jsonify({"message": f"{field_labels} 회원가입 성공!"}), 200

    except Exception as e:
        print(f"[{table}] 에러:", e)
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 노인 회원가입
@app.route('/member/signup', methods=['POST'])
def member_signup():
    return handle_signup(
        table='members',
        columns=['mem_name', 'mem_email', 'mem_tel', 'mem_pw'],
        input_keys=['mem_name', 'mem_email', 'mem_tel', 'mem_pw'],
        field_labels="노인"
    )

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 요양보호사 회원가입
@app.route('/nurse/signup', methods=['POST'])
def nurse_signup():
    return handle_signup(
        table='nurses',
        columns=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        input_keys=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        field_labels="요양보호사"
    )

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 로그인 처리 (순서: members 먼저, nurses 나중)
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        email = data.get('email', '').strip()
        pw = data.get('password', '').strip()

        if not email or not pw:
            return jsonify({"success": False, "error": "이메일 또는 비밀번호를 입력하세요."}), 400

        cur = mysql.connection.cursor()

        # ─── 1) 먼저 members 테이블 조회 ───────────────────────────────────────────
        cur.execute("SELECT mem_name, mem_pw FROM members WHERE mem_email = %s", (email,))
        row_member = cur.fetchone()
        if row_member:
            stored_name, stored_hashed_pw = row_member
            # 비밀번호 비교
            if bcrypt.checkpw(pw.encode('utf-8'), stored_hashed_pw.encode('utf-8')):
                # 로그인 성공 → member
                return jsonify({"success": True, "role": "member", "name": stored_name}), 200
            else:
                return jsonify({"success": False, "error": "비밀번호가 올바르지 않습니다."}), 401

        # ─── 2) members에 없으면, nurses 테이블 조회 ────────────────────────────────
        cur.execute("SELECT nurse_name, nurse_pw FROM nurses WHERE nurse_email = %s", (email,))
        row_nurse = cur.fetchone()
        if row_nurse:
            stored_name, stored_hashed_pw = row_nurse
            # 비밀번호 비교
            if bcrypt.checkpw(pw.encode('utf-8'), stored_hashed_pw.encode('utf-8')):
                # 로그인 성공 → nurse
                return jsonify({"success": True, "role": "nurse", "name": stored_name}), 200
            else:
                return jsonify({"success": False, "error": "비밀번호가 올바르지 않습니다."}), 401

        # ─── 3) 둘 다 없으면 404 ────────────────────────────────────────────────
        return jsonify({"success": False, "error": "존재하지 않는 이메일입니다."}), 404

    except Exception as e:
        print("로그인 에러:", e)
        return jsonify({"success": False, "error": str(e)}), 500

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 서버 실행
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
