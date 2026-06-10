-- MP jobs: Auto Refresh rank 2 and Conserve MP rank 7 at level 1
-- Jobs with native MP rating: WHM(3), BLM(4), RDM(5), PLD(7), DRK(8), SMN(15), BLU(16), SCH(20), GEO(21), RUN(22)

START TRANSACTION;

INSERT INTO traits (traitid, name, job, `level`, `rank`, modifier, value, content_tag, meritid) VALUES
  (10, 'auto refresh', 3, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 4, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 5, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 7, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 8, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 15, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 16, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 20, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 21, 1, 2, 369, 2, NULL, 0),
  (10, 'auto refresh', 22, 1, 2, 369, 2, NULL, 0),
  (13, 'conserve mp', 3, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 4, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 5, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 7, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 8, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 15, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 16, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 20, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 21, 1, 7, 296, 43, NULL, 0),
  (13, 'conserve mp', 22, 1, 7, 296, 43, NULL, 0)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  value = VALUES(value),
  content_tag = VALUES(content_tag),
  meritid = VALUES(meritid);

COMMIT;
