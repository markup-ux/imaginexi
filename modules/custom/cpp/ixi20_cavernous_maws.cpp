/************************************************************************
 * Imagine XI 2.0: cavernous maws visible to every player.
 *
 * namevis 96 is the maw model. Zeroing it removes the portal and leaves
 * the name. Keep 96 on field maws. Cutscene copies stay cutscene-only.
 * Lua ixi20_cavernous_maws.lua grants the Pure White Feather and past-maw
 * teleports so every player can use them.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"

#include "map/entities/npc_entity.h"
#include "map/zone.h"

#include <string_view>
#include <unordered_set>

namespace
{

bool isFieldMaw(CNpcEntity* npc)
{
    if (npc == nullptr || npc->status != xi::Status::Normal)
    {
        return false;
    }

    const std::string_view script = npc->getName();
    if (script == "Cavernous_Maw" || script == "Cavernous_Maw_2")
    {
        return true;
    }

    const std::string_view shown = npc->getPacketName();
    return shown == "Cavernous Maw";
}

} // namespace

class Ixi20CavernousMawsModule : public CPPModule
{
public:
    void OnInit() override
    {
        ShowInfo("Imagine XI 2.0: cavernous maws are visible to every player");
    }

    void OnZoneTick(CZone* PZone) override
    {
        if (PZone == nullptr)
        {
            return;
        }

        const auto zoneId = static_cast<uint16>(PZone->GetID());
        if (!revealedZoneIds_.insert(zoneId).second)
        {
            return;
        }

        PZone->ForEachNpc([](CNpcEntity* npc)
        {
            if (!isFieldMaw(npc))
            {
                return;
            }

            // 96 is retail. Do not clear it; that deletes the maw.
            npc->namevis = static_cast<xi::NameVis>(96);
            npc->setTriggerable(true);
            npc->updatemask |= UPDATE_HP;
        });
    }

private:
    std::unordered_set<uint16> revealedZoneIds_;
};

REGISTER_CPP_MODULE(Ixi20CavernousMawsModule);
