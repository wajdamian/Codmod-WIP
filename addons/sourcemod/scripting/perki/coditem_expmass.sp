#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "ExpMass";
new const String:opis[] = "Dostajesz dodatkowe 500EXP za zabójstwo.";

new bool:ma_item[65];

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
	HookEvent("player_death", SmiercGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (!IsValidClient(attacker) || !IsClientInGame(attacker) || !IsValidClient(client))
		return Plugin_Continue;
		
	if (ma_item[attacker] && GetClientTeam(attacker) != GetClientTeam(client))
		cod_set_user_xp(attacker, cod_get_user_xp(attacker)+500);
	return Plugin_Continue;
}