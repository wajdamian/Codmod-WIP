#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Lekki Snajper";
new const String:opis[] = "1/3 na instakill z SSG08, 0.8 dmg/obrazenia(SSG08), 0.3dmg/obrazenia(fiveseven)";
new const String:bronie[] = "#weapon_ssg08#weapon_fiveseven";
new const inteligencja = 0;
new const zdrowie = 0;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Lekki Snajper",
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
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_ssg08", false))
	{
		if(GetRandomInt(1, 3) == 1)
		{
			if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
				return Plugin_Continue;
			damage = 999.0;
			PrintToChat(attacker, "Instakill!");
			return Plugin_Changed;
		}
		else
		{
		new String:szObrazenia[10];
		new Float:obrazenia_gracza;
		cod_get_user_maks_damage(attacker, szObrazenia, sizeof(szObrazenia));
		obrazenia_gracza = StringToFloat(szObrazenia);
		damage += obrazenia_gracza * 0.8;
		return Plugin_Changed;
		}		
	}
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_fiveseven", false))
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