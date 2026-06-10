-- Server telemetry: sampled job pairs (main/sub) and party compositions (PC-only, per party).
-- Apply this migration, set TELEMETRY_ENABLED = true in settings/map.lua, then restart map.
--
-- Ad-hoc reports (MySQL):
--   SELECT mjob, SUM(sample_count) AS samples FROM server_telemetry_job_samples GROUP BY mjob ORDER BY samples DESC;
--   SELECT mjob, sjob, sample_count FROM server_telemetry_job_samples ORDER BY sample_count DESC LIMIT 20;
--   SELECT setup_key, sample_count FROM server_telemetry_party_setups ORDER BY sample_count DESC LIMIT 20;

CREATE TABLE IF NOT EXISTS `server_telemetry_job_samples` (
    `mjob`         TINYINT(2) UNSIGNED NOT NULL,
    `sjob`         TINYINT(2) UNSIGNED NOT NULL,
    `sample_count` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`mjob`, `sjob`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `server_telemetry_party_setups` (
    `setup_key`    VARCHAR(191) NOT NULL,
    `sample_count` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`setup_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
