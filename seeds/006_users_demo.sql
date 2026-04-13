-- ============================================
-- Seed: Demo users
-- ============================================
-- Passwords are bcrypt hashes of "password123"
-- Generated with cost factor 10
-- In production, each user would have a unique password
-- ============================================

INSERT INTO users (email, password_hash, first_name, last_name, role) VALUES
    ('admin@school.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin', 'Principal', 'admin'),
    ('maria.teacher@school.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Maria', 'Gonzalez', 'teacher'),
    ('carlos.teacher@school.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Carlos', 'Rivera', 'teacher')
ON DUPLICATE KEY UPDATE email = VALUES(email);
