#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>
#include <cstrike>

#define DMG_HEADSHOT (1 << 30)

new const String:nazwa[] = "Dowodca";
new const String:opis[] = "Instakill ze smoke, +25dmg w glowe, odporność na flashe";
new const String:bronie[] = "#weapon_fiveseven#weapon_m4a1#weapon_smokegrenade#weapon_flashbang";
new const inteligencja = 0;
new const zdrowie = 15;
new const obrazenia = 0;
new const wytrzymalosc = 10;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];
new String:sInflictor[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Dowodca",
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
	HookEvent("player_blind", Event_OnFlashPlayer, EventHookMode_Pre);
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

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	if (damagetype == 0)
		return Plugin_Continue;

	GetEdictClassname(inflictor, sInflictor, sizeof(sInflictor));

	if (damagetype & DMG_HEADSHOT && ma_klase[attacker])
		{
			damage+=25.0;
			return Plugin_Changed;
		}

	if(StrEqual(sInflictor, "smokegrenade_projectile",false) && ma_klase[attacker])
	{
		if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
			return Plugin_Continue;

		damage = 999.0;
		PrintToChat(attacker, "Smoke Instakill!");
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action:Event_OnFlashPlayer(Event hEvent, const char[] szEvent, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(hEvent.GetInt("userid"));
	if(ma_klase[iClient])
		SetEntPropFloat(iClient, Prop_Send, "m_flFlashMaxAlpha", 0.5);

	return Plugin_Handled;
}

public Action cod_on_player_blind(int client)
{
	if(ma_klase[client])
		return Plugin_Handled;
	return Plugin_Continue;
}