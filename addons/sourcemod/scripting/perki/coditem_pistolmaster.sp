#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Pistol Master";
new const String:opis[] = "1/LW na natychmiastowe zabójstwo z pistoletu.";

new String:bronie[][] = {
    "weapon_glock",
    "weapon_hkp2000",
	"weapon_usp_silencer",
    "weapon_p250",
    "weapon_fiveseven",
	"weapon_cz75a",
    "weapon_deagle",
    "weapon_elite",
    "weapon_tec9",
	"weapon_revolver"
}
new bool:ma_item[65],
	wartosc_itemu[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 6, 10);
}
public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
	wartosc_itemu[client] = wartosc;
}
public cod_item_disabled(client)
{
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

	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	for (new i = 0; i < sizeof(bronie); i++)
	{
		if(StrEqual(weapon, bronie[i], false))
		{
			new random = GetRandomInt(1,wartosc_itemu[client]);
			if (random == 1)
			{
				damage = 999.0;
				PrintToChat(attacker, "Instakill!");
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}