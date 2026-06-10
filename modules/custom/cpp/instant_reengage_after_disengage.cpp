/************************************************************************
 * Instant Re-Engage After Disengage
 *
 * Removes the client-visible "wait longer" lockout when re-engaging
 * immediately after disengaging by resetting the player's attack timer
 * right before Attack packets are processed.
 *
 * Implemented via OnIncomingPacket because the legacy PacketParser table
 * is not used by the map server's PacketSystem.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/timer.h"

#include "map/ai/ai_container.h"
#include "map/ai/controllers/player_controller.h"
#include "map/entities/charentity.h"
#include "map/map_session.h"
#include "map/packets/basic.h"
#include "map/packets/c2s/0x01a_action.h"

#include "enums/packet_c2s.h"

#include <chrono>

class InstantReengageAfterDisengageModule : public CPPModule
{
    void OnInit() override
    {
        TracyZoneScoped;
    }

    auto OnIncomingPacket(MapSession* /*PSession*/, CCharEntity* PChar, CBasicPacket& packet) -> bool override
    {
        if (packet.getType() != static_cast<uint16>(PacketC2S::GP_CLI_COMMAND_ACTION))
        {
            return false;
        }

        const auto* actionPacket = packet.as<GP_CLI_COMMAND_ACTION>();
        if (actionPacket->ActionID == GP_CLI_COMMAND_ACTION_ACTIONID::Attack && !PChar->PAI->IsEngaged())
        {
            if (auto* controller = dynamic_cast<CPlayerController*>(PChar->PAI->GetController()))
            {
                controller->setLastAttackTime(timer::now() - std::chrono::milliseconds(PChar->GetWeaponDelay(false)));
            }
        }

        return false;
    }
};

REGISTER_CPP_MODULE(InstantReengageAfterDisengageModule);
