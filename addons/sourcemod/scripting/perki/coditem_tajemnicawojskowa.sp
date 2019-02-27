#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Tajemnica wojskowa";
new const String:opis[] = "1/6 na oślepienie wroga, +15 kondycji, +30 HP";

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
	cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)+15);
	cod_set_user_bonus_health(client, cod_get_user_trim(client, 0, 1, 0)+15);
}

public cod_item_disabled(client)
{
	ma_item[client] = false;
	cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)-15);
	cod_set_user_bonus_health(client, cod_get_user_trim(client, 0, 1, 0)-15);
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	int iRandom = GetRandomInt(1,6);
	if (iRandom == 1) 
	{
		cod_perform_blind(client, 2500, 234, 162, 7, 255);
	}

	return Plugin_Continue;
}

