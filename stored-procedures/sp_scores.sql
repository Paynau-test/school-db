-- ============================================
-- Stored Procedures: Scores
-- ============================================

DELIMITER //

-- -----------------------------------------
-- SP: Get scores for a student
-- Returns all subjects for the grade with their
-- score (NULL if not yet recorded)
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_get_scores //
CREATE PROCEDURE sp_get_scores(
    IN p_student_id INT UNSIGNED,
    IN p_grade_id TINYINT UNSIGNED,
    IN p_year SMALLINT UNSIGNED,
    IN p_month TINYINT UNSIGNED
)
BEGIN
    -- Validate student exists
    IF NOT EXISTS (SELECT 1 FROM students WHERE id = p_student_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist.';
    END IF;

    -- Validate month
    IF p_month < 1 OR p_month > 12 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Month must be between 1 and 12.';
    END IF;

    -- Return ALL subjects for the grade with LEFT JOIN
    -- so subjects without a recorded score still appear
    SELECT
        sub.id AS subject_id,
        sub.name AS subject_name,
        sc.score,
        CASE
            WHEN sc.id IS NOT NULL THEN TRUE
            ELSE FALSE
        END AS is_recorded,
        sc.updated_at AS recorded_at
    FROM grade_subject gs
    INNER JOIN subjects sub ON gs.subject_id = sub.id
    LEFT JOIN scores sc
        ON sc.student_id = p_student_id
        AND sc.subject_id = sub.id
        AND sc.grade_id = p_grade_id
        AND sc.year = p_year
        AND sc.month = p_month
    WHERE gs.grade_id = p_grade_id
    ORDER BY sub.name;
END //

-- -----------------------------------------
-- SP: Record (upsert) a score
-- Creates if new, updates if already exists
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_record_score //
CREATE PROCEDURE sp_record_score(
    IN p_student_id INT UNSIGNED,
    IN p_subject_id INT UNSIGNED,
    IN p_grade_id TINYINT UNSIGNED,
    IN p_year SMALLINT UNSIGNED,
    IN p_month TINYINT UNSIGNED,
    IN p_score DECIMAL(4,2)
)
BEGIN
    -- Validate student
    IF NOT EXISTS (SELECT 1 FROM students WHERE id = p_student_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist.';
    END IF;

    -- Validate subject belongs to grade
    IF NOT EXISTS (SELECT 1 FROM grade_subject WHERE grade_id = p_grade_id AND subject_id = p_subject_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Subject does not belong to the specified grade.';
    END IF;

    -- Validate score range
    IF p_score < 0.00 OR p_score > 10.00 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Score must be between 0.00 and 10.00.';
    END IF;

    -- Validate month
    IF p_month < 1 OR p_month > 12 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Month must be between 1 and 12.';
    END IF;

    -- UPSERT: INSERT ... ON DUPLICATE KEY UPDATE
    INSERT INTO scores (student_id, subject_id, grade_id, year, month, score)
    VALUES (p_student_id, p_subject_id, p_grade_id, p_year, p_month, p_score)
    ON DUPLICATE KEY UPDATE
        score = p_score,
        updated_at = CURRENT_TIMESTAMP;

    SELECT
        p_student_id AS student_id,
        p_subject_id AS subject_id,
        p_score AS score,
        CASE
            WHEN ROW_COUNT() = 1 THEN 'created'
            WHEN ROW_COUNT() = 2 THEN 'updated'
            ELSE 'no_change'
        END AS operation;
END //

DELIMITER ;
