#include <sourcemod>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "GROM";
new const String:opis[] = "Po otrzymaniu dmg znika na 3s i jest wtedy odporny na wszystkie granaty";
new const String:bronie[] = "#weapon_m4a1_silencer#weapon_fiveseven";
new const inteligencja = 0;
new const zdrowie = 15;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];
new bool:skillReady[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "GROM",
	version = "1.1",
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
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public cod_class_enabled(client)
{
	ma_klase[client] = true;
	skillReady[client] = true;
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
	if((StrEqual(weapon, "weapon_m4a1_silencer")))
	{
		damage+=5;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(client) || !IsValidClient(attacker))
		return Plugin_Continue;
	
	if (GetClientTeam(client) == GetClientTeam(attacker) || !ma_klase[client])
		return Plugin_Continue;
	
	if (skillReady[client] && IsPlayerAlive(client))
	{
		CreateTimer(3.0, StopInvis, client, TIMER_FLAG_NO_MAPCHANGE);
		SetEntityRenderMode(client, RENDER_TRANSALPHA); 
		SetEntityRenderColor(client, _, _, _, 0);
		if (damagetype & (DMG_BLAST|DMG_BURN))
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public Action:StopInvis(Handle:Timer, any:client)
{
	if (!ma_klase[client])
		return Plugin_Stop;
	skillReady[client] = false;
	SetEntityRenderMode(client, RENDER_TRANSCOLOR); 
	SetEntityRenderColor(client, 255, 255, 255, 255);
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_klase[client])
		return Plugin_Continue;

	skillReady[client] = true;
	return Plugin_Continue;
}