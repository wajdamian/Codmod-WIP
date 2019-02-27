#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

native set_user_esp(client, wartosc);
native get_user_esp(client);

new const String:nazwa[] = "Oczy Cheatera";
new const String:opis[] = "Masz wallhack przez 3 sekundy po uzyciu";

new bool:ma_item[65];
new bool:canUse[65];

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
	HookEvent("player_spawn", OdrodzenieGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	canUse[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
	set_user_esp(client, 0);
}

public cod_item_used(client)
{
	if (canUse[client])
	{
		new serial = GetClientSerial(client)
		CreateTimer(3.0, DisableESP, serial, TIMER_FLAG_NO_MAPCHANGE);
		set_user_esp(client, 1);
		canUse[client] = false;
	}
}

public Action:DisableESP(Handle:Timer, any:serial)
{
	new client = GetClientFromSerial(serial);
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	set_user_esp(client, 0);
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;
	
	if (!canUse[client])
		canUse[client] = true;
	
	return Plugin_Continue;
}