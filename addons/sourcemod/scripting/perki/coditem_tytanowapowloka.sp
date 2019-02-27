#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Tytanowa powloka";
new const String:opis[] = "Jestes odporny na noze";

new bool:ma_item[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "glodny jestem",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[client])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(StrContains(weapon, "knife") || StrContains(weapon, "bayonet"))
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}