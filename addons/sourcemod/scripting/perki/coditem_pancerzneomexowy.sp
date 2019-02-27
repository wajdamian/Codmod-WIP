#include <sourcemod>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "Pancerz Neomexowy";
new const String:opis[] = "Masz 1/LW szansy na odbicie pocisku";

new bool:ma_item[65],
	wartosc_itemu[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 3, 6);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
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
public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	if(!IsValidClient(attacker) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	if(GetRandomInt(1, wartosc_itemu[client]) == 1)
	{
		cod_inflict_damage(attacker, client, RoundFloat(damage));
		return Plugin_Handled;
	}

	return Plugin_Continue;
}