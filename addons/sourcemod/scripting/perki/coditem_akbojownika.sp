#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "AK bojownika";
new const String:opis[] = "Dostajesz ak47 oraz + 7dmg z niego";
new const String:bronie[] = "#weapon_ak47";

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
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public cod_item_enabled(client)
{
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));

	new String:weapons2[256];
	Format(weapons2, sizeof(weapons2), "%s%s", weapons, bronie);

	cod_set_user_bonus_weapons(client, weapons2);
	ma_item[client] = true;
	if(ma_item[client] && IsPlayerAlive(client))
	{
		new ent = GetPlayerWeaponSlot(client, 0);
		if(ent != -1)
			AcceptEntityInput(ent, "Kill");
		GivePlayerItem(client, "weapon_ak47");
	}
}
public cod_item_disabled(client)
{
	new String:weapons[256];
	cod_get_user_bonus_weapons(client, weapons, sizeof(weapons));
	ReplaceString(weapons, sizeof(weapons), bronie, "");

	cod_set_user_bonus_weapons(client, weapons);
	ma_item[client] = false;
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(StrEqual(weapon, "weapon_ak47") && damagetype & DMG_BULLET)
	{
		damage+=7;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

