#include <sourcemod>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "Bezlik Ammo";
new const String:opis[] = "Posiadasz nieskończoną ilość naboi w magazynku";

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
	HookEvent("bullet_impact", StrzalGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public Action:StrzalGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	new active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(active_weapon != -1)
		SetEntData(active_weapon, FindSendPropInfo("CWeaponCSBase", "m_iClip1"),5);

	return Plugin_Continue;
}