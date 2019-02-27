#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Rusher";
new const String:opis[] = "Posiada 1/20 szansy na natychmiastowe zabicie z Novy";
new const String:bronie[] = "#weapon_nova#weapon_p250";
new const inteligencja = 10;
new const zdrowie = 0;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 30;
new bool:ma_klase[65];
new const flagi;


public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Cod Klasa",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public cod_class_enabled(client)
{
	ma_klase[client] = true;
}
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}
public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	new randomInt = GetRandomInt(1,6);
	if((StrEqual(weapon, "weapon_nova")) && (GetClientButtons(attacker) & IN_ATTACK) && (randomInt==1))
	{
		if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
			return Plugin_Continue;
		damage = 999.0;
		PrintToChat(attacker, "Instakill!");
		return Plugin_Changed;
	}
	return Plugin_Continue;
}