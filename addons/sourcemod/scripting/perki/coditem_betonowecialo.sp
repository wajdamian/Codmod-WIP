#define DMG_HEADSHOT	(1 << 30)
#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Betonowe cialo";
new const String:opis[] = "Jestes odporny na kazdy dmg przez 3s OD OTRZYMANIA DMG KURWA KACZKA oraz mozna cie zabic jedynie headshotem";

new bool:ma_item[65],
	bool:jestNiewrazliwy[65];
	
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
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	jestNiewrazliwy[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[client])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
	
	CreateTimer(3.0, JestWrazliwy, client);
	if(!(damagetype & DMG_HEADSHOT) && jestNiewrazliwy[client])
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:JestWrazliwy(Handle:Timer, any:client)
{
	if (IsClientInGame(client) && ma_item[client])
		jestNiewrazliwy[client] = false;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	jestNiewrazliwy[client] = true;
	return Plugin_Continue;
}