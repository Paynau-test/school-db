-- ============================================
-- Migration 001: Create base tables
-- Normalized data model for school system
-- ============================================

-- Grades (1st through 9th)
CREATE TABLE IF NOT EXISTS grades (
    id TINYINT UNSIGNED NOT NULL,
    name VARCHAR(10) NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Subjects
CREATE TABLE IF NOT EXISTS subjects (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_subject_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- N:M relationship between grades and subjects
-- Defines which subjects are taught in each grade
CREATE TABLE IF NOT EXISTS grade_subject (
    grade_id TINYINT UNSIGNED NOT NULL,
    subject_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (grade_id, subject_id),
    CONSTRAINT fk_gs_grade FOREIGN KEY (grade_id) REFERENCES grades(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_gs_subject FOREIGN KEY (subject_id) REFERENCES subjects(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Students
CREATE TABLE IF NOT EXISTS students (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(60) NOT NULL,
    last_name_father VARCHAR(60) NOT NULL,
    last_name_mother VARCHAR(60) DEFAULT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other') NOT NULL,
    grade_id TINYINT UNSIGNED NOT NULL,
    status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_student_grade FOREIGN KEY (grade_id) REFERENCES grades(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- Index for partial name search
    INDEX idx_student_name (first_name, last_name_father, last_name_mother),
    INDEX idx_student_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Scores
-- One score per student, per subject, per month
CREATE TABLE IF NOT EXISTS scores (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id INT UNSIGNED NOT NULL,
    subject_id INT UNSIGNED NOT NULL,
    grade_id TINYINT UNSIGNED NOT NULL,
    year SMALLINT UNSIGNED NOT NULL,
    month TINYINT UNSIGNED NOT NULL,
    score DECIMAL(4,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    -- Unique constraint: one score per student/subject/grade/year/month
    UNIQUE KEY uk_score (student_id, subject_id, grade_id, year, month),
    CONSTRAINT fk_score_student FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_score_subject FOREIGN KEY (subject_id) REFERENCES subjects(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_score_grade FOREIGN KEY (grade_id) REFERENCES grades(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- Validation: score between 0 and 10
    CONSTRAINT chk_score_range CHECK (score >= 0.00 AND score <= 10.00),
    -- Validation: month between 1 and 12
    CONSTRAINT chk_month_valid CHECK (month >= 1 AND month <= 12),
    -- Index for main query: lookup by student + grade + month
    INDEX idx_score_lookup (student_id, grade_id, year, month)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
