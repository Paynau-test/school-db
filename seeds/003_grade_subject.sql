-- ============================================
-- Seed: Grade-Subject relationship
-- Grades 1-6 (elementary): core subjects
-- Grades 7-9 (middle school): + Physics, Chemistry, Biology
-- ============================================

-- Core subjects for all grades (1-9)
INSERT IGNORE INTO grade_subject (grade_id, subject_id)
SELECT g.id, s.id
FROM grades g
CROSS JOIN subjects s
WHERE s.name IN ('Matematicas', 'Espanol', 'Historia', 'Geografia', 'Educacion Civica', 'Educacion Fisica', 'Educacion Artistica', 'Ingles');

-- Natural Sciences only for elementary (grades 1-6)
INSERT IGNORE INTO grade_subject (grade_id, subject_id)
SELECT g.id, s.id
FROM grades g
CROSS JOIN subjects s
WHERE g.id BETWEEN 1 AND 6
AND s.name = 'Ciencias Naturales';

-- Physics, Chemistry, Biology only for middle school (grades 7-9)
INSERT IGNORE INTO grade_subject (grade_id, subject_id)
SELECT g.id, s.id
FROM grades g
CROSS JOIN subjects s
WHERE g.id BETWEEN 7 AND 9
AND s.name IN ('Fisica', 'Quimica', 'Biologia');
