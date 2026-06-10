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

#include "0x01c_unknown.h"

#include "entities/charentity.h"

auto GP_CLI_COMMAND_UNKNOWN::validate(MapSession* PSession, const CCharEntity* PChar) const -> PacketValidationResult
{
    // Not implemented.
    return PacketValidator(PChar)
        .blockedBy({ BlockedState::InEvent });
}

void GP_CLI_COMMAND_UNKNOWN::process(MapSession* PSession, CCharEntity* PChar) const
{
    static_cast<void>(PSession);
    static_cast<void>(PChar);
    // Expected traffic with pets out (e.g. after Activate); not an error. Avoid ShowDebug so it is not confused with failures.
    ShowTrace("GP_CLI_COMMAND_UNKNOWN (0x01C): targid=%u padding=%u field08=%u", this->unknown00, this->padding00, this->unknown01);
}
