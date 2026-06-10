/*
===========================================================================

  Copyright (c) 2025 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "0x112_battlefield_req.h"

#include "battlefield.h"
#include "entities/charentity.h"
#include "utils/charutils.h"

auto GP_CLI_COMMAND_BATTLEFIELD_REQ::validate(MapSession* PSession, const CCharEntity* PChar) const -> PacketValidationResult
{
    return PacketValidator(PChar)
        .oneOf<GP_CLI_COMMAND_BATTLEFIELD_REQ_KIND>(this->Kind);
}

void GP_CLI_COMMAND_BATTLEFIELD_REQ::process(MapSession* PSession, CCharEntity* PChar) const
{
    // Client 0x112 asks for battlefield sidebar / map-overlay data (e.g. after login). A noop leaves
    // some builds waiting on objective UI state and can fault. Reply with 0x075 (same as timer helpers).
    // XiPackets: Kind 0 requests *both* channels — some clients expect more than one 0x075 in that case.
    if (PChar->PBattlefield != nullptr)
    {
        charutils::SendTimerPacket(PChar, PChar->PBattlefield->GetRemainingTime());
        return;
    }

    // Zero-duration countdown sets OBJECTIVEUTILITY_COUNTDOWN with Duration=0 — clients show a stuck 0:00 bar.
    // Empty 0x075 (no countdown flag) matches battlefield leave / Lua countdown with no argument.
    charutils::SendClearTimerPacket(PChar);
    if (this->Kind == static_cast<uint8_t>(GP_CLI_COMMAND_BATTLEFIELD_REQ_KIND::Both))
    {
        charutils::SendClearTimerPacket(PChar);
    }
}
