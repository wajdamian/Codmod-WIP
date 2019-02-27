#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Smoke dowodcy";
new const String:opis[] = "Natychmiastowe zabojstwo od uderzenia granatem dymnym.";

new const String:bronie[] = "#weapon_smokegrenade";
new bool:ma_item[65];
new String:sInflictor[65];
public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "laki luj szczela w huj",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
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
		GivePlayerItem(client, "weapon_smokegrenade");
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

	GetEdictClassname(inflictor, sInflictor, sizeof(sInflictor));

	if(StrEqual(sInflictor, "smokegrenade_projectile",false))
	{
		damage = 999.0;
		PrintToChat(attacker, "Smoke Instakill!");
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

