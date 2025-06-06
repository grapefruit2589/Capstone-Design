DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS nurses;

-- ================================================
-- ③ members 테이블 생성
-- ================================================
CREATE TABLE members (
    mem_id    INT           NOT NULL AUTO_INCREMENT,   -- 회원 고유 ID (자동 증가)
    mem_name  VARCHAR(10)   NOT NULL,                  -- 회원 이름 (최대 10자)
    mem_email VARCHAR(50)   NOT NULL UNIQUE,           -- 회원 이메일 (유일제약)
    mem_tel   VARCHAR(20)   NOT NULL UNIQUE,           -- 회원 전화번호 (유일제약)
    mem_pw    VARCHAR(255)  NOT NULL,                  -- 회원 비밀번호 (해시된 문자열 기준으로 255자)
    PRIMARY KEY (mem_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ================================================
-- ④ nurses 테이블 생성
-- ================================================
CREATE TABLE nurses (
    nurse_id    INT           NOT NULL AUTO_INCREMENT,  -- 요양보호사 고유 ID (자동 증가)
    nurse_name  VARCHAR(50)   NOT NULL,                 -- 요양보호사 이름
    nurse_email VARCHAR(100)  NOT NULL UNIQUE,          -- 요양보호사 이메일
    nurse_tel   VARCHAR(20)   NOT NULL UNIQUE,          -- 요양보호사 전화번호
    nurse_pw    VARCHAR(255)  NOT NULL,                 -- 요양보호사 비밀번호(해시 문자열 기준)
    PRIMARY KEY (nurse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

USE capston_db;
SELECT * FROM members;
SELECT * FROM nurses;



