/************************************************************************
 * Imagine XI 2.0: planar rifts visible to every player.
 *
 * namevis 100 is the swirl. Zeroing it leaves the nameplate. The client
 * still drops that mesh once the camera is close, because the entity
 * packet never sets the "keep drawing when the camera is inside" bit.
 * That bit is not stored on the NPC, so each nearby update is patched
 * before it is sent.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/timer.h"

#include "map/entities/char_entity.h"
#include "map/entities/npc_entity.h"
#include "map/enums/packet_s2c.h"
#include "map/zone.h"

#include <chrono>
#include <string_view>
#include <unordered_map>
#include <unordered_set>

namespace
{

constexpr float kRiftRange = 50.0f;
constexpr auto  kRefresh   = std::chrono::milliseconds(1000);

// Byte 0x28 of the 0x0E. CliPriorityFlag keeps the mesh in the render
// list. OcclusionoffFlag keeps it when the camera is inside the swirl.
constexpr uint8 kKeepVisible = 0x20 | 0x80;

bool isPlanarRift(CNpcEntity* npc)
{
    if (npc == nullptr || npc->status != xi::Status::Normal)
    {
        return false;
    }

    const std::string_view script = npc->getName();
    if (script == "Planar_Rift")
    {
        return true;
    }

    const std::string_view shown = npc->getPacketName();
    return shown == "Planar Rift";
}

bool nearRift(CCharEntity* player, CNpcEntity* npc)
{
    const float dx = player->loc.p.x - npc->loc.p.x;
    const float dy = player->loc.p.y - npc->loc.p.y;
    const float dz = player->loc.p.z - npc->loc.p.z;
    return dx * dx + dy * dy + dz * dz < kRiftRange * kRiftRange;
}

void keepRiftVisible(CBasicPacket* packet)
{
    if (packet == nullptr)
    {
        return;
    }

    const uint8 mask = packet->ref<uint8>(0x0A);
    if ((mask & UPDATE_DESPAWN) != 0 || (mask & UPDATE_HP) == 0)
    {
        return;
    }

    packet->ref<uint8>(0x28) |= kKeepVisible;
    packet->ref<uint8>(0x2B) = 100;
}

} // namespace

class Ixi20PlanarRiftsModule : public CPPModule
{
public:
    void OnInit() override
    {
        ShowInfo("Imagine XI 2.0: planar rifts are visible to every player");
    }

    void OnCharZoneOut(CCharEntity* PChar) override
    {
        if (PChar != nullptr)
        {
            refreshedAt_.erase(PChar->id);
        }
    }

    void OnZoneTick(CZone* PZone) override
    {
        if (PZone == nullptr)
        {
            return;
        }

        const auto zoneId = static_cast<uint16>(PZone->GetID());
        if (revealedZoneIds_.insert(zoneId).second)
        {
            PZone->ForEachNpc([](CNpcEntity* npc)
            {
                if (!isPlanarRift(npc))
                {
                    return;
                }

                // 100 is the swirl. Do not clear it.
                npc->namevis = static_cast<xi::NameVis>(100);
                npc->updatemask |= UPDATE_HP;
            });
        }

        const auto now = timer::now();

        PZone->ForEachChar([&](CCharEntity* player)
        {
            if (player == nullptr || player->inMogHouse())
            {
                return;
            }

            for (const auto& pending : player->getPacketList())
            {
                if (pending == nullptr || pending->getType() != static_cast<uint16>(PacketS2C::GP_SERV_COMMAND_CHAR_NPC))
                {
                    continue;
                }

                auto* entity = player->GetEntity(pending->ref<uint16>(0x08), TYPE_NPC);
                if (isPlanarRift(dynamic_cast<CNpcEntity*>(entity)))
                {
                    keepRiftVisible(pending.get());
                }
            }

            const auto seen = refreshedAt_.find(player->id);
            if (seen != refreshedAt_.end() && now - seen->second < kRefresh)
            {
                return;
            }

            bool refreshed = false;
            PZone->ForEachNpc([&](CNpcEntity* npc)
            {
                if (!isPlanarRift(npc) || !nearRift(player, npc))
                {
                    return;
                }

                player->updateEntityPacket(npc, ENTITY_UPDATE, static_cast<uint8>(UPDATE_HP | UPDATE_LOOK));
                refreshed = true;
            });

            if (!refreshed)
            {
                return;
            }

            for (const auto& pending : player->getPacketList())
            {
                if (pending == nullptr || pending->getType() != static_cast<uint16>(PacketS2C::GP_SERV_COMMAND_CHAR_NPC))
                {
                    continue;
                }

                auto* entity = player->GetEntity(pending->ref<uint16>(0x08), TYPE_NPC);
                if (isPlanarRift(dynamic_cast<CNpcEntity*>(entity)))
                {
                    keepRiftVisible(pending.get());
                }
            }

            refreshedAt_[player->id] = now;
        });
    }

private:
    std::unordered_set<uint16>                 revealedZoneIds_;
    std::unordered_map<uint32, timer::time_point> refreshedAt_;
};

REGISTER_CPP_MODULE(Ixi20PlanarRiftsModule);
