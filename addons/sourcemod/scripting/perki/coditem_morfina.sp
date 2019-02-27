#include <sourcemod>
#include <sdkhooks>
#include <cstrike>
#include <codmod>

new const String:nazwa[] = "Morfina";
new const String:opis[] = "Posiadasz 1/LW szans na ponowne odrodzenia sie po smierci";

new bool:ma_item[65],
	wartosc_itemu[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu & de duk goos quak m8",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 2, 4);
	HookEvent("player_death", SmiercGracza);
}
public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
	wartosc_itemu[client] = wartosc;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public Action:SmiercGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	if(!IsValidClient(killer) || GetClientTeam(client) == GetClientTeam(killer))
		return Plugin_Continue;

	if(GetRandomInt(1, wartosc_itemu[client]) == 1)
		CreateTimer(0.1, Wskrzeszenie, client, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}
public Action:Wskrzeszenie(Handle:timer, any:client)
{
	if(!IsValidClient(client))
		return Plugin_Continue;

	CS_RespawnPlayer(client);
	return Plugin_Continue;
}