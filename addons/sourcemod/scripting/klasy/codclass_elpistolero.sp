#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "El Pistolero";
new const String:opis[] = "Moze kupic kazdy pistolet, +10DMG, odporny na instakille prócz noża, modul odrzutowy co 5 sek.";
new const String:bronie[] = "#weapon_p250";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:skillReady[65];
new bool:ma_klase[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "El Pistolero",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
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
	if(damagetype & (DMG_BULLET) && GetClientButtons(attacker) & IN_ATTACK)
	{
		damage+=10;
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
		
	if (IsPlayerAlive(client))
	{
		new String:weapon[32];
		GetClientWeapon(attacker, weapon, sizeof(weapon));
		if ((!StrEqual(weapon, "weapon_bayonet") || StrContains(weapon, "weapon_knife", false) == -1) && (damagetype & (DMG_GENERIC)) && damage > 800)
		{
			damage = 0.0;
			PrintToChat(client,"Zapobiegles instakillowi!")
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public cod_class_skill_used(client)
{	
	if (skillReady[client] && ma_klase[client])
	{
		new Float:forigin[3];
		GetClientEyePosition(client, forigin);

		new Float:fangles[3];
		GetClientEyeAngles(client, fangles);
		new Float:iorigin[3], Float:iangles[3], Float:ivector[3];
		TR_TraceRayFilter(forigin, fangles, MASK_SOLID, RayType_Infinite, TraceRayFilter, client);
		TR_GetEndPosition(iorigin);
		MakeVectorFromPoints(forigin, iorigin, ivector);
		NormalizeVector(ivector, ivector);
		ScaleVector(ivector, 1000.0);
		GetVectorAngles(ivector, iangles);
		ivector[2]-=ivector[2];
		ivector[2]+=300;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, ivector);
		skillReady[client] = false;
		CreateTimer(5.0, SkillRenewal, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public bool:TraceRayFilter(ent, contents)
{
	return false;
}

public Action:SkillRenewal(Handle:timer, any:client)
{
	if (!ma_klase[client])
		return Plugin_Stop;
	skillReady[client] = true;
	PrintToChat(client, "Mozesz znowu uzyc umiejetnosci!");
	return Plugin_Continue;
}