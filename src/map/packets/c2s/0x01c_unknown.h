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

#pragma once

#include "base.h"

// https://github.com/atom0s/XiPackets/tree/main/world/client/0x001C
// Client->server notify when the player uses a job ability while a pet is active (retail purpose otherwise unknown).
// unknown00 matches the client's current target index (often 0x400 / 1024 for the first dynamic entity, e.g. a pet).
// No map response is required; ability flow is handled by other packets (e.g. 0x01A action).
GP_CLI_PACKET(GP_CLI_COMMAND_UNKNOWN,
              uint16_t unknown00; // Target index (targid), per XiPackets.
              uint16_t padding00; // Padding; unused.
              uint32_t unknown01; // Observed as 1 on retail.
);
