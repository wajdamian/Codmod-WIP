#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Typowy Seba";
new const String:opis[] = "Masz natychmiastowo zabijającego, 10-strzałowego zeusa";

new const String:bronie[] = "#weapon_taser";

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
	HookEvent("player_spawn", OdrodzenieGracza);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public cod_item_enabled(client)
{
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));

	new String:weapons2[256];
	Format(weapons2, sizeof(weapons2), "%s%s", weapons, bronie);
	cod_set_user_bonus_weapons(client, weapons2);
	ma_item[client] = true;
	if(ma_item[client] && IsPlayerAlive(client)) GivePlayerItem(client, "weapon_taser");
	SetEntData(2, FindSendPropInfo("CWeaponCSBase", "m_iClip1"),10);
}
public cod_item_disabled(client)
{
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));
	ReplaceString(weapons, sizeof(weapons), bronie, "");

	cod_set_user_bonus_weapons(client, weapons);
	ma_item[client] = false;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if (!IsValidClient || !ma_item[client])
		return Plugin_Continue;
	
	new userID = GetEventInt(event, "userid");
	CreateTimer(0.2, TaserAmmo, userID, TIMER_FLAG_NO_MAPCHANGE)
	return Plugin_Continue;
}

public Action:TaserAmmo(Handle:Timer, any:userID)
{
	new client = GetClientOfUserId(userID)
	if (!IsValidClient(client) || !ma_item[client])
		return Plugin_Handled;
	
	SetEntData(2, FindSendPropInfo("CWeaponCSBase", "m_iClip1"), 10);
	return Plugin_Handled;
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(StrEqual(weapon, "weapon_taser") && GetClientButtons(attacker & IN_ATTACK))
	{
		damage = 999.0;
		PrintToChat(attacker, "Instakill!");
		return Plugin_Changed;
	}	
	return Plugin_Continue;
}
