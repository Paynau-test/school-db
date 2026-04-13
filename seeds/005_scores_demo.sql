-- ============================================
-- Seed: Demo scores
-- Some subjects with scores, others without
-- (to test the LEFT JOIN in sp_get_scores)
-- ============================================

-- Juan Carlos Garcia (id=1, grade 3) - January 2026
-- Only some subjects recorded
CALL sp_record_score(1, 1, 3, 2026, 1, 9.50);  -- Matematicas
CALL sp_record_score(1, 2, 3, 2026, 1, 8.00);  -- Espanol
CALL sp_record_score(1, 4, 3, 2026, 1, 7.50);  -- Historia

-- Maria Fernanda Martinez (id=2, grade 4) - January 2026
CALL sp_record_score(2, 1, 4, 2026, 1, 10.00); -- Matematicas
CALL sp_record_score(2, 2, 4, 2026, 1, 9.00);  -- Espanol
CALL sp_record_score(2, 3, 4, 2026, 1, 8.50);  -- Ciencias Naturales
CALL sp_record_score(2, 4, 4, 2026, 1, 9.20);  -- Historia
CALL sp_record_score(2, 5, 4, 2026, 1, 8.80);  -- Geografia

-- Carlos Eduardo Hernandez (id=5, grade 7 - middle school) - January 2026
CALL sp_record_score(5, 1, 7, 2026, 1, 7.00);  -- Matematicas
CALL sp_record_score(5, 9, 7, 2026, 1, 8.50);  -- Fisica
CALL sp_record_score(5, 10, 7, 2026, 1, 9.00); -- Quimica
