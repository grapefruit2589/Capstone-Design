DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS nurses;

-- 🔹 members 테이블
CREATE TABLE members (
    mem_id    INT           NOT NULL AUTO_INCREMENT,
    mem_name  VARCHAR(10)   NOT NULL,
    mem_email VARCHAR(50)  NOT NULL UNIQUE,
    mem_tel   VARCHAR(20)   NOT NULL UNIQUE,
    mem_pw    VARCHAR(255)  NOT NULL UNIQUE,
    PRIMARY KEY (mem_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 🔹 nurses 테이블
CREATE TABLE nurses (
    nurse_id    INT           NOT NULL AUTO_INCREMENT,
    nurse_name  VARCHAR(50)   NOT NULL,
    nurse_email VARCHAR(100)  NOT NULL UNIQUE,
    nurse_tel   VARCHAR(20)   NOT NULL UNIQUE,
    nurse_pw    VARCHAR(255)  NOT NULL UNIQUE,
    PRIMARY KEY (nurse_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 🔹 선택된 DB와 조회
USE capston_app;
SELECT * FROM members;
SELECT * FROM nurses;


