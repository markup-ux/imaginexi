-----------------------------------
-- Gil replacing former quest scroll rewards (scrolls removed from economy).
-- Tuned to 75-cap private-server style pricing: common magic scrolls often
-- list around ~2–4x retail vendor (BaseSell) on AH; teleports / recall / Warp II
-- higher demand. Instant Warp remains a separate utility scroll reward, not gil.
-- Reference bands: EdenXI / similar-era AH listings vs NPC sellback.
-----------------------------------
xi.questScrollGilReward = xi.questScrollGilReward or {}

xi.questScrollGilReward.BLAZE_SPIKES   = 2500
xi.questScrollGilReward.ASPIR          = 6000
xi.questScrollGilReward.WARP_II        = 18000
xi.questScrollGilReward.TELEPORT_MEA   = 13000
xi.questScrollGilReward.DRAIN          = 2200
xi.questScrollGilReward.MAGES_BALLAD   = 2800
xi.questScrollGilReward.UTSUSEMI_ICHI  = 9000
xi.questScrollGilReward.TELEPORT_ALTEP = 13500
xi.questScrollGilReward.HOJO_ICHI      = 6500
xi.questScrollGilReward.JUBAKU_ICHI    = 8500
xi.questScrollGilReward.KURAYAMI_ICHI  = 3500
xi.questScrollGilReward.DOKUMORI_ICHI  = 3500
xi.questScrollGilReward.RETRACE        = 16000
xi.questScrollGilReward.RECALL_PASHH   = 11500
xi.questScrollGilReward.WARP           = 2100
xi.questScrollGilReward.TELEPORT_DEM   = 14500
