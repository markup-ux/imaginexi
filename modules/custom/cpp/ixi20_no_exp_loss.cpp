/************************************************************************
 * Imagine XI 2.0: no experience loss on death (module only).
 *
 * Stock KO loss is map.EXP_RETAIN (0 keeps none of it, 1 keeps all).
 * This forces retain to 1, so a death does not drain the exp bar or
 * delevel. Raise does not pay back experience that was never lost.
 * GM !takexp still removes experience (forced loss ignores retain).
 * A settings reload reads map.lua again; the next time-server tick
 * puts retain back. Comment this line out of init.txt and rebuild
 * xi_map to restore loss.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/lua.h"
#include "common/settings.h"

namespace
{

void publishRetain()
{
    sol::object mapSettings = lua["xi"]["settings"]["map"];
    if (mapSettings.valid() && mapSettings.get_type() == sol::type::table)
    {
        mapSettings.as<sol::table>()["EXP_RETAIN"] = 1.0;
    }
}

void applyRetain()
{
    if (settings::get<uint8>("map.EXP_RETAIN") == 1)
    {
        return;
    }

    settings::set("map.EXP_RETAIN", 1.0);
    publishRetain();
}

} // namespace

class Ixi20NoExpLossModule : public CPPModule
{
public:
    void OnInit() override
    {
        applyRetain();
        ShowInfo("Imagine XI 2.0: no experience loss on death");
    }

    void OnTimeServerTick() override
    {
        applyRetain();
    }
};

REGISTER_CPP_MODULE(Ixi20NoExpLossModule);
