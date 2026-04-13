-- ============================================
-- Seed: Grades (1st through 9th)
-- ============================================

INSERT INTO grades (id, name) VALUES
    (1, 'primero'),
    (2, 'segundo'),
    (3, 'tercero'),
    (4, 'cuarto'),
    (5, 'quinto'),
    (6, 'sexto'),
    (7, 'septimo'),
    (8, 'octavo'),
    (9, 'noveno')
ON DUPLICATE KEY UPDATE name = VALUES(name);
