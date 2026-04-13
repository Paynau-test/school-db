-- ============================================
-- Seed: Subjects
-- ============================================

INSERT INTO subjects (name) VALUES
    ('Matematicas'),
    ('Espanol'),
    ('Ciencias Naturales'),
    ('Historia'),
    ('Geografia'),
    ('Educacion Civica'),
    ('Educacion Fisica'),
    ('Educacion Artistica'),
    ('Fisica'),
    ('Quimica'),
    ('Biologia'),
    ('Ingles')
ON DUPLICATE KEY UPDATE name = VALUES(name);
