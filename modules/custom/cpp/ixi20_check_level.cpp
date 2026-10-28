/************************************************************************
 * Imagine XI 2.0: /check level on notorious monsters.
 *
 * Normal checks already send the mob level as the first battle-message
 * parameter. The client sentence prints it after the check-text DAT
 * patch. Impossible-to-gauge checks send 0, so this fills that
 * parameter before the packet leaves. No extra chat line is sent.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"

#include "map/entities/base_entity.h"
#include "map/entities/char_entity.h"
#include "map/entities/mob_entity.h"
#include "map/enums/msg_basic.h"
#include "map/enums/packet_s2c.h"
#include "map/packets/basic.h"

#include "data/enums/mod.h"

namespace
{

// GP_SERV_HEADER (4) + UniqueNoCas (4) + UniqueNoTar (4)
constexpr std::size_t kTargetIdOffset = 0x08;
constexpr std::size_t kLevelOffset    = 0x0C;
constexpr std::size_t kTargetIndexOffset = 0x16;
constexpr std::size_t kMessageOffset  = 0x18;

auto shownLevel(CMobEntity* mob) -> int32
{
    const int32 adjusted = mob->GetMLevel() + mob->getMod(xi::Mod::EXP_LVL_MOD);
    if (adjusted > 0)
    {
        return adjusted;
    }
    return mob->GetMLevel();
}

} // namespace

class Ixi20CheckLevelModule : public CPPModule
{
public:
    void OnInit() override
    {
        ShowInfo("Imagine XI 2.0: /check level in the check sentence");
    }

    void OnPushPacket(CCharEntity* PChar, const std::unique_ptr<CBasicPacket>& packet) override
    {
        if (PChar == nullptr || packet == nullptr)
        {
            return;
        }

        if (packet->getType() != static_cast<uint16>(PacketS2C::GP_SERV_COMMAND_BATTLE_MESSAGE))
        {
            return;
        }

        if (static_cast<MsgBasic>(packet->ref<uint16>(kMessageOffset)) != MsgBasic::CheckImpossibleToGauge)
        {
            return;
        }

        if (packet->ref<uint32>(kLevelOffset) != 0)
        {
            return;
        }

        const uint16 targetIndex = packet->ref<uint16>(kTargetIndexOffset);
        const uint32 targetId    = packet->ref<uint32>(kTargetIdOffset);
        auto*        mob         = dynamic_cast<CMobEntity*>(PChar->GetEntity(targetIndex, TYPE_MOB));
        if (mob == nullptr || mob->id != targetId)
        {
            return;
        }

        const int32 level = shownLevel(mob);
        if (level > 0)
        {
            packet->ref<uint32>(kLevelOffset) = static_cast<uint32>(level);
        }
    }
};

REGISTER_CPP_MODULE(Ixi20CheckLevelModule);
