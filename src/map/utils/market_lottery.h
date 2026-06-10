/*
===========================================================================

  Market lottery: NPC vendor sales fund a weekly gil pool; one weighted
  winner receives the pool when conquest weekly tally completes.

===========================================================================
*/

#pragma once

#include "common/cbasetypes.h"

class CCharEntity;

namespace market_lottery
{
    // Returns gil the player receives after lottery tax (records ticket weight for the current period).
    uint32 playerVendorPayoutAfterTax(CCharEntity* PChar, uint32 grossGilFromVendor);

    // Runs at end of weekly conquest tally (map server, once per cycle).
    void onWeeklyConquestTallyEnd();
} // namespace market_lottery
