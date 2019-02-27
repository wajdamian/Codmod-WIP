#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Lodowe pociski";
new const String:opis[] = "Masz 1/10 szansy na zamrozenie wroga na 2s.";

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
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
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
		
	if(damagetype & (DMG_BULLET) && GetClientButtons(attacker) & IN_ATTACK)
	{
		new random = GetRandomInt(1, 10);
		if(random == 1)
		{
			new mrozonka = GetClientUserId(client);
			SetEntityMoveType(client, MOVETYPE_NONE);
			PrintToChat(attacker,"Zamroziles przeciwnika!");
			CreateTimer(2.0, Zamrozenie, mrozonka, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action:Zamrozenie(Handle:timer, mrozonka)
{
	new client = GetClientOfUserId(mrozonka);
	if (!IsClientInGame(client) || !IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;
		
	SetEntityMoveType(client, MOVETYPE_WALK);
	return Plugin_Continue;
}