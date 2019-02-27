#include <sourcemod>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "Noz Komandosa";
new const String:opis[] = "Natychmiastowe zabicie z kosy (PPM)";

new bool:ma_item[65];
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
	cod_register_item(nazwa, opis, 0, 0);
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
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if((StrEqual(weapon, "weapon_bayonet") || StrContains(weapon, "weapon_knife", false) != -1) && damagetype & (DMG_SLASH|DMG_BULLET)  && GetClientButtons(attacker) & IN_ATTACK2)
	{	
		damage = 999.0;
		PrintToChat(attacker, "Instakill!");
		return Plugin_Changed;
	}	
	return Plugin_Continue;
}