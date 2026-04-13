-- ============================================
-- Stored Procedures: Users / Auth
-- ============================================
-- NOTE: Password hashing is NOT done here.
-- The API layer (Node.js / C#) handles bcrypt
-- hashing before calling these procedures.
-- The DB only stores and retrieves the hash.
-- ============================================

DELIMITER //

-- -----------------------------------------
-- SP: Register a new user
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_create_user //
CREATE PROCEDURE sp_create_user(
    IN p_email VARCHAR(120),
    IN p_password_hash VARCHAR(255),
    IN p_first_name VARCHAR(60),
    IN p_last_name VARCHAR(60),
    IN p_role ENUM('admin', 'teacher')
)
BEGIN
    IF p_email IS NULL OR TRIM(p_email) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email is required.';
    END IF;

    IF p_password_hash IS NULL OR TRIM(p_password_hash) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password hash is required.';
    END IF;

    IF EXISTS (SELECT 1 FROM users WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email already registered.';
    END IF;

    INSERT INTO users (email, password_hash, first_name, last_name, role)
    VALUES (TRIM(LOWER(p_email)), p_password_hash, TRIM(p_first_name), TRIM(p_last_name), p_role);

    SELECT LAST_INSERT_ID() AS user_id;
END //

-- -----------------------------------------
-- SP: Get user by email (for login)
-- Returns the hash so the API can verify it
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_get_user_by_email //
CREATE PROCEDURE sp_get_user_by_email(
    IN p_email VARCHAR(120)
)
BEGIN
    SELECT
        id,
        email,
        password_hash,
        first_name,
        last_name,
        role,
        is_active
    FROM users
    WHERE email = TRIM(LOWER(p_email))
    AND is_active = TRUE;
END //

-- -----------------------------------------
-- SP: Get user by ID (for JWT verification)
-- Does NOT return the password hash
-- -----------------------------------------
DROP PROCEDURE IF EXISTS sp_get_user_by_id //
CREATE PROCEDURE sp_get_user_by_id(
    IN p_user_id INT UNSIGNED
)
BEGIN
    SELECT
        id,
        email,
        first_name,
        last_name,
        role,
        is_active,
        created_at
    FROM users
    WHERE id = p_user_id
    AND is_active = TRUE;
END //

DELIMITER ;
