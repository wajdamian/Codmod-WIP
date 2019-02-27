#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "No-Flash";
new const String:opis[] = "Jestes odporny na flashe oraz otrzymujesz FlashBang";

new bool:ma_item[65];
new String:bronie[] = "#weapon_flashbang";

public Plugin:myinfo =
{
	name = nazwa,
	author = ".nbd",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/geneccc"
};

public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
	HookEvent("player_blind", Event_OnFlashPlayer, EventHookMode_Pre);
}

public cod_item_enabled(client)
{
	ma_item[client] = true;
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));

	new String:weapons2[256];
	Format(weapons2, sizeof(weapons2), "%s%s", weapons, bronie);
	cod_set_user_bonus_weapons(client, weapons2);
	GivePlayerItem(client, "weapon_flashbang");
}

public cod_item_disabled(client)
{
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));
	ReplaceString(weapons, sizeof(weapons), bronie, "");

	cod_set_user_bonus_weapons(client, weapons);
	ma_item[client] = false;
}

public Action:Event_OnFlashPlayer(Event hEvent, const char[] szEvent, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if(ma_item[iClient])
		SetEntPropFloat(iClient, Prop_Send, "m_flFlashMaxAlpha", 0.5);

	return Plugin_Handled;
}

public Action cod_on_player_blind(int client)
{
	if(ma_item[client])
		return Plugin_Handled;
	return Plugin_Continue;
}