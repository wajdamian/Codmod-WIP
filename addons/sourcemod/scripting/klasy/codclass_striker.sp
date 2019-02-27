#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Striker [P]";
new const String:opis[] = "No-recoil, 15hp za killa, +5dmg, leczy sie +65hp raz na runde.";
new const String:bronie[] = "#weapon_bizon#weapon_p250";
new const inteligencja = 0;
new const zdrowie = 0;
new const obrazenia = 0;
new const wytrzymalosc = 10;
new const kondycja = 10;
new const flagi =  ADMFLAG_CUSTOM5;

new bool:ma_klase[65];
new bool:skillReady[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Striker [P]",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	CreateTimer(0.1, ZarejestrujDevklase);
	HookEvent("player_spawn", OdrodzenieGracza);
	HookEvent("player_death", SmiercGracza);
}
public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
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
	skillReady[client] = true;
	ma_klase[client] = true;
	EnableNoRecoil(client);
} 
public cod_class_disabled(client)
{
	ma_klase[client] = false;
	DisableNoRecoil(client);
}
public cod_class_skill_used(client)
{	
	if (skillReady[client] && ma_klase[client])
	{
		SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (GetClientHealth(client)+65 < cod_get_user_maks_health(client))? GetClientHealth(client)+65 : cod_get_user_maks_health(client));
		PrintToChat(client, "Zostales uleczony!");
		skillReady[client] = false;
	}
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!ma_klase[client] || !IsValidClient(client))
		return Plugin_Continue;
	
	skillReady[client] = true;
	return Plugin_Continue;
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
	
	damage += 5;
	return Plugin_Changed;
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(killer) || !ma_klase[killer])
		return Plugin_Continue;

	if(!IsValidClient(client) || !IsPlayerAlive(killer))
		return Plugin_Continue;

	if(GetClientTeam(client) == GetClientTeam(killer))
		return Plugin_Continue;

	new zdrowie_gracza = GetClientHealth(killer);
	new maksymalne_zdrowie = cod_get_user_maks_health(killer);
	SetEntData(killer, FindDataMapInfo(killer, "m_iHealth"), (zdrowie_gracza+15 < maksymalne_zdrowie)? zdrowie_gracza+15: maksymalne_zdrowie);
	return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!ma_klase[client] || !IsValidClient(client))
		return Plugin_Continue;
	if (GetClientButtons(client) & IN_ATTACK)
	{
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", NULL_VECTOR);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public EnableNoRecoil(client)
{
	SendConVarValue(client, FindConVar("weapon_accuracy_nospread"), "1");
	SendConVarValue(client, FindConVar("weapon_recoil_cooldown"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_cooldown"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_decay1_exp"), "99999");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_exp"), "99999");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_lin"), "99999");
	SendConVarValue(client, FindConVar("weapon_recoil_scale"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_suppression_shots"), "500");
}
public DisableNoRecoil(client)
{
	SendConVarValue(client, FindConVar("weapon_accuracy_nospread"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_cooldown"), "0.55");
	SendConVarValue(client, FindConVar("weapon_recoil_decay1_exp"), "3.5");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_exp"), "8");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_lin"), "18");
	SendConVarValue(client, FindConVar("weapon_recoil_scale"), "2");
	SendConVarValue(client, FindConVar("weapon_recoil_suppression_shots"), "4");
}