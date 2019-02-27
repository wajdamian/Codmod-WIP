#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Szpieg";
new const String:opis[] = "1/3 na x2 dmg, +10dmg, cichy bieg";
new const String:bronie[] = "#weapon_usp_silencer#weapon_flashbang#weapon_flashbang";
new const inteligencja = 0;
new const zdrowie = 5;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Szpieg",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	HookEvent("player_spawn", OdrodzenieGracza);
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
	
	for (new i = 0; i<MAXPLAYERS+1; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
		{
			new String:modelName[64];
			GetClientModel(i, modelName, sizeof(modelName));
			SetEntityModel(client, modelName);
			break;
		}
	}
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
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK))
	{
		if(GetRandomInt(1, 3) == 1)
		{
			damage = 2*damage+10;
			return Plugin_Changed;
		}
		
		damage +=10;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_klase[client])
		return Plugin_Continue;

	for (new i = 0; i<MAXPLAYERS+1; i++)
	{
		if (IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client))
		{
			new String:modelName[64];
			GetClientModel(i, modelName, sizeof(modelName));
			SetEntityModel(client, modelName);
			break;
		}
	}
	return Plugin_Continue;
}