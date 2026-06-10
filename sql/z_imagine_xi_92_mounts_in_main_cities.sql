-- Feature: Allow mounts in main cities
-- Sets MISC_MOUNT (0x0004) on primary city zones.

UPDATE zone_settings
SET misc = misc | 0x0004
WHERE zoneid IN (
    230,231,232,233,      -- San d'Oria
    234,235,236,237,      -- Bastok
    238,239,240,241,242,  -- Windurst
    243,244,245,246       -- Jeuno
);
