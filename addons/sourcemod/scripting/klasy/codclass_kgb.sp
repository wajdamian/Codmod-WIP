#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "KGB";
new const String:opis[] = "Leczy 5hp za kazde trafienie, +5DMG";
new const String:bronie[] = "#weapon_ak47#weapon_glock";
new const inteligencja = 0;
new const zdrowie = 15;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "KGB",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
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
	if(damagetype & (DMG_BULLET) && GetClientButtons(attacker) & IN_ATTACK)
	{
		damage+=5;
		new zdrowie_gracza = GetClientHealth(attacker);
		new maksymalne_zdrowie = cod_get_user_maks_health(attacker);
		SetEntData(attacker, FindDataMapInfo(attacker, "m_iHealth"), (zdrowie_gracza+5 < maksymalne_zdrowie)? zdrowie_gracza+5: maksymalne_zdrowie);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}