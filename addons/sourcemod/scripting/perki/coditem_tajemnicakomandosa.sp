#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Tajemnica Komandosa";
new const String:opis[] = "Masz 2hp, +60 kondycji, mozna cie zabic tylko nozem, 1/2 na instakill z ppm nozem";

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
	HookEvent("player_spawn", OdrodzenieGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	SetEntData(client, FindDataMapInfo(client, "m_iHealth"), 2);
	cod_set_user_bonus_health(client, cod_get_user_health(client, 0, 1, 0)-200);
	cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)-60);
}

public cod_item_disabled(client)
{
	ma_item[client] = false;
	cod_set_user_bonus_health(client, cod_get_user_health(client, 0, 1, 0)+200);
	cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)-60);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if((StrContains(weapon, "knife") || StrContains(weapon, "bayonet")) && GetClientButtons(attacker) & IN_ATTACK2)
	{
		new random = GetRandomInt(1,2);
		if (random == 1)
		{
			damage = 999.0;
			PrintToChat(attacker, "Instakill!");
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
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
		return Plugin_Continue;

	damage = 0.0;
	return Plugin_Changed;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;
	
	SetEntData(client, FindDataMapInfo(client, "m_iHealth"), 2);
	return Plugin_Continue;
}