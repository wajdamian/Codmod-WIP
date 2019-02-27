#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Snajper";
new const String:opis[] = "Zadaje 1,5x obrażeń z AWP; dodatkowo [+1 * SIŁA] z AWP; [0.3 * SIŁA] z Deagle";
new const String:bronie[] = "#weapon_awp#weapon_deagle";
new const inteligencja = 0;
new const zdrowie = 0;
new const obrazenia = 0;
new const wytrzymalosc = 25;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Snajper",
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
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_awp", false))
	{
		new String:szObrazenia[10];
		new Float:obrazenia_gracza;
		cod_get_user_maks_damage(attacker, szObrazenia, sizeof(szObrazenia));
		obrazenia_gracza = StringToFloat(szObrazenia);
		damage = RoundFloat(damage*1.5)+obrazenia_gracza;
		return Plugin_Changed;
	}
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_deagle", false))
	{
		new String:szObrazenia[10];
		new Float:obrazenia_gracza;
		cod_get_user_maks_damage(attacker, szObrazenia, sizeof(szObrazenia));
		obrazenia_gracza = StringToFloat(szObrazenia);
		damage += obrazenia_gracza * 0.3;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}