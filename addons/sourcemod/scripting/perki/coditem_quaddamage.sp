#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Quad Damage";
new const String:opis[] = "Zadajesz czterokrotnie wiekszy dmg przez 5s.";

new bool:ma_item[65];
new bool:itemInUse[65];
new bool:canUse[65];

public Plugin:myinfo =
{
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
public cod_item_enabled(client)
{
	ma_item[client] = true;
	canUse[client] = true;
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

public cod_item_used(client)
{
	if (canUse[client])
	{
		PrintToChat(client, "Odpaliłeś Quad Damage!");
		itemInUse[client] = true;
		canUse[client] = false;
		new userid = GetClientUserId(client);
		CreateTimer(5.0, DisableItem, userid, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	if(itemInUse[attacker])
	{
		damage = damage*4;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:DisableItem(Handle:Timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !ma_item[client])
		return Plugin_Handled;
		
	itemInUse[client] = false;
	PrintToChat(client, "Quad damage się skończył.");
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if (ma_item[client])
	{
		canUse[client] = true;
	}
	return Plugin_Continue;
}