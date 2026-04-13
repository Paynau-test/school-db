-- ============================================
-- Stored Procedures: Student CRUD
-- ============================================

DELIMITER //

-- -----------------------------------------
-- SP: Create student
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_create_student //
CREATE PROCEDURE sp_create_student(
    IN p_first_name VARCHAR(60),
    IN p_last_name_father VARCHAR(60),
    IN p_last_name_mother VARCHAR(60),
    IN p_date_of_birth DATE,
    IN p_gender ENUM('M', 'F', 'Other'),
    IN p_grade_id TINYINT UNSIGNED
)
BEGIN
    -- Validate required fields
    IF p_first_name IS NULL OR TRIM(p_first_name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required.';
    END IF;

    IF p_last_name_father IS NULL OR TRIM(p_last_name_father) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Father last name is required.';
    END IF;

    IF p_date_of_birth IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth is required.';
    END IF;

    IF p_date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth cannot be in the future.';
    END IF;

    -- Validate grade exists
    IF NOT EXISTS (SELECT 1 FROM grades WHERE id = p_grade_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Specified grade does not exist.';
    END IF;

    INSERT INTO students (first_name, last_name_father, last_name_mother, date_of_birth, gender, grade_id, status)
    VALUES (TRIM(p_first_name), TRIM(p_last_name_father), TRIM(p_last_name_mother), p_date_of_birth, p_gender, p_grade_id, 'active');

    SELECT LAST_INSERT_ID() AS student_id;
END //

-- -----------------------------------------
-- SP: Get student by ID
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_get_student //
CREATE PROCEDURE sp_get_student(
    IN p_student_id INT UNSIGNED
)
BEGIN
    SELECT
        s.id,
        s.first_name,
        s.last_name_father,
        s.last_name_mother,
        s.date_of_birth,
        s.gender,
        s.grade_id,
        g.name AS grade_name,
        s.status,
        s.created_at,
        s.updated_at
    FROM students s
    INNER JOIN grades g ON s.grade_id = g.id
    WHERE s.id = p_student_id;
END //

-- -----------------------------------------
-- SP: Search students by name (partial match)
-- Searches across first_name + last names
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_search_students //
CREATE PROCEDURE sp_search_students(
    IN p_term VARCHAR(180),
    IN p_status ENUM('active', 'inactive', 'suspended'),
    IN p_limit INT UNSIGNED,
    IN p_offset INT UNSIGNED
)
BEGIN
    SET p_limit = IFNULL(p_limit, 20);
    SET p_offset = IFNULL(p_offset, 0);

    SELECT
        s.id,
        s.first_name,
        s.last_name_father,
        s.last_name_mother,
        s.date_of_birth,
        s.gender,
        s.grade_id,
        g.name AS grade_name,
        s.status
    FROM students s
    INNER JOIN grades g ON s.grade_id = g.id
    WHERE
        (p_term IS NULL OR p_term = '' OR
            s.id = CAST(p_term AS UNSIGNED) OR
            CONCAT(s.first_name, ' ', s.last_name_father, ' ', IFNULL(s.last_name_mother, '')) LIKE CONCAT('%', p_term, '%'))
        AND (p_status IS NULL OR s.status = p_status)
    ORDER BY s.last_name_father, s.last_name_mother, s.first_name
    LIMIT p_limit OFFSET p_offset;
END //

-- -----------------------------------------
-- SP: Update student
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_update_student //
CREATE PROCEDURE sp_update_student(
    IN p_student_id INT UNSIGNED,
    IN p_first_name VARCHAR(60),
    IN p_last_name_father VARCHAR(60),
    IN p_last_name_mother VARCHAR(60),
    IN p_date_of_birth DATE,
    IN p_gender ENUM('M', 'F', 'Other'),
    IN p_grade_id TINYINT UNSIGNED,
    IN p_status ENUM('active', 'inactive', 'suspended')
)
BEGIN
    -- Validate student exists
    IF NOT EXISTS (SELECT 1 FROM students WHERE id = p_student_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist.';
    END IF;

    IF p_first_name IS NULL OR TRIM(p_first_name) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'First name is required.';
    END IF;

    IF p_last_name_father IS NULL OR TRIM(p_last_name_father) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Father last name is required.';
    END IF;

    IF p_date_of_birth > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Date of birth cannot be in the future.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM grades WHERE id = p_grade_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Specified grade does not exist.';
    END IF;

    UPDATE students SET
        first_name = TRIM(p_first_name),
        last_name_father = TRIM(p_last_name_father),
        last_name_mother = TRIM(p_last_name_mother),
        date_of_birth = p_date_of_birth,
        gender = p_gender,
        grade_id = p_grade_id,
        status = p_status
    WHERE id = p_student_id;

    SELECT ROW_COUNT() AS rows_affected;
END //

-- -----------------------------------------
-- SP: Delete student (soft delete -> inactive)
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_delete_student //
CREATE PROCEDURE sp_delete_student(
    IN p_student_id INT UNSIGNED
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM students WHERE id = p_student_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student does not exist.';
    END IF;

    UPDATE students SET status = 'inactive' WHERE id = p_student_id;

    SELECT ROW_COUNT() AS rows_affected;
END //

DELIMITER ;
