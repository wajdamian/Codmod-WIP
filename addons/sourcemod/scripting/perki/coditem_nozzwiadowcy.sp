#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Noz Zwiadowcy";
new const String:opis[] = "+60 kondycji na nozu";

new bool:ma_item[65];
new preModTrim[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
	HookEvent("item_equip", ItemEquip);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	preModTrim[client] = cod_get_user_trim(client, 0, 1, 0);
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public Action:ItemEquip(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;
	
	new weapon = GetEventInt(event, "weptype");
	if (weapon == 0)
	{
	cod_set_user_bonus_trim(client,preModTrim[client]+60);
	}
	else
		cod_set_user_bonus_trim(client, preModTrim[client]);
	return Plugin_Continue;
}