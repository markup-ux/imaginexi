-- Imagine XI 2.0: advertise this public IPv4 to clients after character select.
-- Replace 0.0.0.0 with your own public address before remote players zone.
-- On the host machine, tools/scripts/sync_public_zoneip.ps1 rewrites this file when the WAN address changes.
UPDATE `zone_settings` SET `zoneip` = '0.0.0.0' WHERE `zoneport` > 0;
