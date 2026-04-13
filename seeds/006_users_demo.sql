-- ============================================
-- Seed: Demo users
-- ============================================
-- Passwords are bcrypt hashes of "password123"
-- Generated with bcryptjs, cost factor 10
-- In production, each user would have a unique password
-- ============================================

INSERT INTO users (email, password_hash, first_name, last_name, role) VALUES
    ('admin@school.com', '$2b$10$0bSHVVndP2L81/KlIu1/JueNEqNOnrhLPoWuW195lsUnJYGOgz0SG', 'Admin', 'Principal', 'admin'),
    ('maria.teacher@school.com', '$2b$10$0bSHVVndP2L81/KlIu1/JueNEqNOnrhLPoWuW195lsUnJYGOgz0SG', 'Maria', 'Gonzalez', 'teacher'),
    ('carlos.teacher@school.com', '$2b$10$0bSHVVndP2L81/KlIu1/JueNEqNOnrhLPoWuW195lsUnJYGOgz0SG', 'Carlos', 'Rivera', 'teacher')
ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash);
