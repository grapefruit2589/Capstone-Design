from flask import Flask, request, jsonify
from flask_mysqldb import MySQL
import bcrypt

app = Flask(__name__)

# MySQL 연결 설정
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = '0000'
app.config['MYSQL_DB'] = 'homework_db'

mysql = MySQL(app)

# 🔹 노인 회원가입
@app.route('/member/signup', methods=['POST'])
def member_signup():
    try:
        data = request.json
        print("[회원] 받은 데이터:", data)

        mem_name = data.get('mem_name', '').strip()
        mem_gen = data.get('mem_gen', '').strip()
        mem_pw = data.get('mem_pw', '').strip()
        mem_tel = data.get('mem_tel', '').strip()

        if not all([mem_name, mem_gen, mem_pw, mem_tel]):
            return jsonify({"error": "입력값이 비어 있습니다."}), 400

        # 중복 확인
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM members WHERE mem_tel = %s OR mem_pw = %s", (mem_tel, mem_pw))
        existing = cur.fetchone()
        if existing:
            return jsonify({"error": "이미 존재하는 전화번호 또는 비밀번호입니다."}), 409

        hashed_pw = bcrypt.hashpw(mem_pw.encode('utf-8'), bcrypt.gensalt())

        cur.execute("""
            INSERT INTO members (mem_name, mem_gen, mem_pw, mem_tel)
            VALUES (%s, %s, %s, %s)
        """, (mem_name, mem_gen, hashed_pw.decode('utf-8'), mem_tel))
        mysql.connection.commit()
        cur.close()

        print("[회원] DB 저장 성공")
        return jsonify({"message": "회원가입 성공!"})

    except Exception as e:
        print("[회원] 에러:", e)
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500

# 🔹 사회복지사 회원가입
@app.route('/worker/signup', methods=['POST'])
def worker_signup():
    try:
        data = request.json
        print("[사회복지사] 받은 데이터:", data)

        worker_name = data.get('worker_name', '').strip()
        worker_gen = data.get('worker_gen', '').strip()
        worker_pw = data.get('worker_pw', '').strip()
        worker_tel = data.get('worker_tel', '').strip()
        worker_email = data.get('worker_email', '').strip()

        if not all([worker_name, worker_gen, worker_pw, worker_tel, worker_email]):
            return jsonify({"error": "입력값이 비어 있습니다."}), 400

        # 중복 확인
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT * FROM social_workers WHERE worker_tel = %s OR worker_email = %s OR worker_pw = %s
        """, (worker_tel, worker_email, worker_pw))
        existing = cur.fetchone()
        if existing:
            return jsonify({"error": "이미 등록된 전화번호, 이메일 또는 비밀번호입니다."}), 409

        hashed_pw = bcrypt.hashpw(worker_pw.encode('utf-8'), bcrypt.gensalt())

        cur.execute("""
            INSERT INTO social_workers (worker_name, worker_gen, worker_pw, worker_tel, worker_email)
            VALUES (%s, %s, %s, %s, %s)
        """, (worker_name, worker_gen, hashed_pw.decode('utf-8'), worker_tel, worker_email))
        mysql.connection.commit()
        cur.close()

        print("[사회복지사] DB 저장 성공")
        return jsonify({"message": "사회복지사 회원가입 성공!"})

    except Exception as e:
        print("[사회복지사] 에러:", e)
        mysql.connection.rollback()
        return jsonify({"error": str(e)}), 500

# 서버 실행
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
