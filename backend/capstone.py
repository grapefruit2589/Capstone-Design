from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL
import bcrypt

app = Flask(__name__)
# CORS: 모든 Origin 허용
CORS(app, resources={r"/*": {"origins": "*"}})

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 MySQL 연결 설정 (자신의 환경에 맞게 수정)
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '0000'
app.config['MYSQL_DB'] = 'capston_db'   # 실제 DB 이름으로 변경

mysql = MySQL(app)

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 서버 상태 체크용
@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "pong"}), 200

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 회원가입 공통 처리 함수 (수정 불필요)
def handle_signup(table, columns, input_keys, field_labels):
    try:
        data = request.json or {}
        print(f"[{table}] 받은 데이터:", data)

        # 1) 필수 입력값 추출
        values = [data.get(k, '').strip() for k in input_keys]
        if not all(values):
            return jsonify({"error": "입력값이 비어 있습니다."}), 400

        cur = mysql.connection.cursor()

        # 2) 이메일 또는 전화번호 중복 체크
        check_query = f"SELECT 1 FROM {table} WHERE {columns[1]} = %s OR {columns[2]} = %s"
        cur.execute(check_query, (values[1], values[2]))
        if cur.fetchone():
            cur.close()
            return jsonify({"error": "이미 존재하는 이메일 또는 전화번호입니다."}), 409

        # 3) 비밀번호 해싱
        hashed_pw = bcrypt.hashpw(values[3].encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

        # 4) INSERT 쿼리 실행
        insert_query = f"""
            INSERT INTO {table} ({', '.join(columns)})
            VALUES (%s, %s, %s, %s)
        """
        cur.execute(insert_query, (values[0], values[1], values[2], hashed_pw))
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
# 🔹 요양보호사 회원가입 (원본 /nurse/signup)
@app.route('/nurse/signup', methods=['POST'])
def nurse_signup():
    return handle_signup(
        table='nurses',
        columns=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        input_keys=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        field_labels="요양보호사"
    )

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 플러터 화면이 /caregiver/signup 으로 요청을 보내는 경우, 내부적으로 키만 매핑하여 handle_signup 호출
@app.route('/caregiver/signup', methods=['POST'])
def caregiver_signup():
    data = request.json or {}
    # Flutter 에서 넘어오는 키: caregiver_name, caregiver_email, caregiver_tel, caregiver_pw
    mapped_data = {
        "nurse_name": data.get("caregiver_name", "").strip(),
        "nurse_email": data.get("caregiver_email", "").strip(),
        "nurse_tel": data.get("caregiver_tel", "").strip(),
        "nurse_pw": data.get("caregiver_pw", "").strip(),
    }
    # request.json을 덮어쓰기
    request.json.clear()
    request.json.update(mapped_data)

    return handle_signup(
        table='nurses',
        columns=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        input_keys=['nurse_name', 'nurse_email', 'nurse_tel', 'nurse_pw'],
        field_labels="요양보호사"
    )

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 로그인 처리 (role 값으로 분기)
@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json or {}
        email = data.get('email', '').strip()
        pw    = data.get('password', '').strip()
        role  = data.get('role', '').strip()   # client에서 전달한 role (member 또는 nurse)

        if not email or not pw or not role:
            return jsonify({"success": False, "error": "이메일, 비밀번호, 역할을 모두 입력하세요."}), 400

        cur = mysql.connection.cursor()

        # ───────────────────────────────────────────────────────────────────────
        # 🔸 role이 "member"인 경우: members 테이블 조회
        if role == 'member':
            cur.execute("SELECT mem_name, mem_pw FROM members WHERE mem_email = %s", (email,))
            row_member = cur.fetchone()
            if not row_member:
                cur.close()
                return jsonify({"success": False, "error": "노인 계정이 존재하지 않습니다."}), 404

            stored_name, stored_hashed_pw = row_member
            if bcrypt.checkpw(pw.encode('utf-8'), stored_hashed_pw.encode('utf-8')):
                cur.close()
                return jsonify({"success": True, "role": "member", "name": stored_name}), 200
            else:
                cur.close()
                return jsonify({"success": False, "error": "비밀번호가 올바르지 않습니다."}), 401

        # ───────────────────────────────────────────────────────────────────────
        # 🔸 role이 "nurse"인 경우: nurses 테이블 조회
        elif role == 'nurse':
            cur.execute("SELECT nurse_name, nurse_pw FROM nurses WHERE nurse_email = %s", (email,))
            row_nurse = cur.fetchone()
            if not row_nurse:
                cur.close()
                return jsonify({"success": False, "error": "요양보호사 계정이 존재하지 않습니다."}), 404

            stored_name, stored_hashed_pw = row_nurse
            if bcrypt.checkpw(pw.encode('utf-8'), stored_hashed_pw.encode('utf-8')):
                cur.close()
                return jsonify({"success": True, "role": "nurse", "name": stored_name}), 200
            else:
                cur.close()
                return jsonify({"success": False, "error": "비밀번호가 올바르지 않습니다."}), 401

        # ───────────────────────────────────────────────────────────────────────
        # 🔸 role 값이 member 또는 nurse가 아닐 때
        else:
            cur.close()
            return jsonify({"success": False, "error": "유효하지 않은 사용자 역할입니다."}), 400

    except Exception as e:
        print("로그인 에러:", e)
        return jsonify({"success": False, "error": str(e)}), 500

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 긴급 호출 처리 (/emergency)
#   • 요청 body: { "mem_name": "노인 이름" }
#   1) mem_name으로 members 테이블에서 mem_id 조회
#   2) mem_id가 없으면 404 리턴
#   3) mem_id와 동일한 nurse_id로 nurses 조회
#      • 간호사가 있으면 → { "nurse_name": "요양보호사 이름" }
#      • 없으면 → DB에 등록된 가장 낮은 nurse_id(첫 번째 요양보호사)를 조회
#          – 한 명이라도 있으면 → 그 요양보호사 이름 반환
#          – 등록된 요양보호사가 없으면 → 112 연결 메시지 반환
@app.route('/emergency', methods=['POST'])
def emergency():
    try:
        data = request.json or {}
        mem_name = data.get("mem_name", "").strip()

        # 1) mem_name 필수 체크
        if not mem_name:
            return jsonify({"error": "mem_name 키에 노인 이름을 담아주세요."}), 400

        cur = mysql.connection.cursor()

        # 2) members 테이블에서 해당 mem_name의 mem_id 조회
        cur.execute("SELECT mem_id FROM members WHERE mem_name = %s", (mem_name,))
        row = cur.fetchone()
        if not row:
            cur.close()
            return jsonify({"error": f"{mem_name} 어르신이 존재하지 않습니다."}), 404

        mem_id = row[0]

        # 3) nurses 테이블에서 mem_id와 동일한 nurse_id 조회
        cur.execute("SELECT nurse_name FROM nurses WHERE nurse_id = %s", (mem_id,))
        nurse_row = cur.fetchone()

        # 4) 만약 mem_id에 딱 맞는 요양보호사가 있으면 바로 반환
        if nurse_row:
            nurse_name = nurse_row[0]
            cur.close()
            return jsonify({"nurse_name": nurse_name}), 200

        # 5) 매칭되는 nurse_id가 없을 때, "대체 요양보호사"를 찾아본다.
        #    – 가장 낮은 nurse_id(첫 번째 등록된 요양보호사)를 불러오기
        cur.execute("SELECT nurse_name FROM nurses ORDER BY nurse_id LIMIT 1")
        fallback = cur.fetchone()
        cur.close()

        if fallback:
            fallback_name = fallback[0]
            return jsonify({"nurse_name": fallback_name}), 200
        else:
            # 6) 아예 등록된 요양보호사가 한 명도 없으면 112 연결 메시지
            final_message = (
                "현재 담당 요양보호사가 배정되어 있지 않아, "
                "긴급 상황 발생 시 자동으로 112에 연결되었습니다. "
                "잠시만 기다려주세요."
            )
            return jsonify({"message": final_message}), 200

    except Exception as e:
        print("긴급 호출 에러:", e)
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500

# ─────────────────────────────────────────────────────────────────────────────
# 🔹 서버 실행
if __name__ == '__main__':
    # 운영 환경에서는 host/port, debug 모드를 환경변수나 별도 설정 파일로 관리하는 것이 좋습니다.
    app.run(host='0.0.0.0', port=5000, debug=True)
