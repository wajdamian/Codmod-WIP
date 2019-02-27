#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Tajemnica Generala";
new const String:opis[] = "Masz 1/LW szanse na natychmiastowe zabojstwo z granatu odlamkowego";

new bool:ma_item[65],
	wartosc_itemu[65];
new String:bronie[] = "weapon_hegrenade";

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
	cod_register_item(nazwa, opis, 3, 5);
}
public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));

	new String:weapons2[256];
	Format(weapons2, sizeof(weapons2), "%s%s", weapons, bronie);
	cod_set_user_bonus_weapons(client, weapons2);
	wartosc_itemu[client] = wartosc;
	GivePlayerItem(client, "weapon_hegrenade");
}

public cod_item_disabled(client)
{	
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));
	ReplaceString(weapons, sizeof(weapons), bronie, "");

	cod_set_user_bonus_weapons(client, weapons);
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
	
	new String:Weapon[32];
	GetEdictClassname(inflictor, Weapon, sizeof(Weapon));
	if(StrEqual(Weapon, "weapon_hegrenade") || StrContains(Weapon, "he") != -1)
	{
		new random = GetRandomInt(1, wartosc_itemu[client]);
		if (random == 1)
		{
			damage = 999.0;
			PrintToChat(attacker, "Instakill!");
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

