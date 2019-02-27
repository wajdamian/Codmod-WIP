#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "Tajemnica Chachmenta";
new const String:opis[] = "1/LW na zmianę broni przeciwnika na nóż";

new bool:ma_item[65];
new wartosc_itemu[65];

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
	cod_register_item(nazwa, opis, 5, 10);
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

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage)
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	if(GetRandomInt(1,wartosc_itemu[client]) == 1)
	{
		int iWeapon = GetPlayerWeaponSlot(client, 2);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", iWeapon);
	}
	return Plugin_Continue;
}

