#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Plonace naboje";
new const String:opis[] = "1/5 na podpalenie przeciwnika za 5+0.2int DMG na 3 sekundy.";

new bool:ma_item[65];
new bool:podpalony[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Cod perk",
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
	
	new random = GetRandomInt(1,5);
	if (random == 1)
	{
		podpalony[client] = true;
		new userid = GetClientUserId(client);
		CreateTimer(3.0, DzwonPoStrazaka, userid, TIMER_FLAG_NO_MAPCHANGE);
		DataPack hData;
		CreateDataTimer(1.0,  PlonGnoju, hData, TIMER_REPEAT);
		WritePackCell(hData, GetClientSerial(client));
		WritePackCell(hData, GetClientSerial(attacker));
	}
	return Plugin_Continue;
}

public Action:DzwonPoStrazaka(Handle:Timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsClientInGame(client) || !podpalony[client])
		return Plugin_Handled;
	
	podpalony[client] = false;
	return Plugin_Continue;
}

public Action:PlonGnoju(Handle:Timer, Handle:hData)
{
	ResetPack(hData);
	new victim = GetClientFromSerial(ReadPackCell(hData));
	new attacker = GetClientFromSerial(ReadPackCell(hData));
	if (!IsValidClient(victim) || !IsPlayerAlive(victim) || !podpalony[victim])
		return Plugin_Stop;

	cod_inflict_damage(victim, attacker, 5+RoundToFloor(cod_get_user_maks_intelligence(attacker)*0.2));
	return Plugin_Continue;
}