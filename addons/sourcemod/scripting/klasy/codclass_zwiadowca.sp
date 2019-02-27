#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Zwiadowca";
new const String:opis[] = "Posiada teleport przed siebie, co 25 int kolejny teleport. +5dmg";
new const String:bronie[] = "#weapon_mp5sd#weapon_cz75a";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 0;
new const wytrzymalosc = 10;
new const kondycja = 5;
new const flagi = 0;

new bool:ma_klase[65];
new ilosc_teleportow_gracza[65];
new Float:time_gracza[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Zwiadowca",
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
	ilosc_teleportow_gracza[client] = 1 + RoundToFloor(cod_get_user_maks_intelligence(client) * 0.04);
	time_gracza[client] = 0.0;
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
		
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK))
	{
		damage += 5;
		return Plugin_Changed;
	
	}
	
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !IsClientInGame(client) || !ma_klase[client])
		return Plugin_Continue;
	
	ilosc_teleportow_gracza[client] = 1 + RoundToFloor(cod_get_user_maks_intelligence(client) * 0.04);
	return Plugin_Continue;
}

public cod_class_skill_used(client)
{
	new Float:gametime = GetGameTime();
	if (ma_klase[client] && ilosc_teleportow_gracza[client] > 0 && gametime > time_gracza[client]+1.0)
	{
		new Float:forigin[3];
		GetClientEyePosition(client, forigin);
		new Float:fangles[3];
		GetClientEyeAngles(client, fangles);
		new Float:iorigin[3], Float:iangles[3], Float:ivector[3];
		
		TR_TraceRayFilter(forigin, fangles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayFilter, client);
		TR_GetEndPosition(iorigin);
	
		for (new i = 0; i < 28; i++)
		{
			MakeVectorFromPoints(forigin, iorigin, ivector);
			ivector[2] = 0.0;
			NormalizeVector(ivector, ivector);
			ScaleVector(ivector, 750.0 - i*25);
			GetVectorAngles(ivector, iangles);
			new Float:tpVector[3];
			tpVector[0] = forigin[0] + ivector[0];
			tpVector[1] = forigin[1] + ivector[1];
			tpVector[2] = forigin[2] + ivector[2] - 30;
			
			TeleportEntity(client, tpVector, iangles, NULL_VECTOR);
			if (IsPlayerStuck(client))
			{
				ilosc_teleportow_gracza[client]--;
				break;
			}
		}
		time_gracza[client] = gametime;
	}
}

stock IsPlayerStuck(client){
    decl Float:vecMin[3], Float:vecMax[3], Float:vecOrigin[3];
    
    GetClientMins(client, vecMin);
    GetClientMaxs(client, vecMax);
    
    GetClientAbsOrigin(client, vecOrigin);
    
    TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_PLAYERSOLID, TraceRayDontHitPlayerAndWorld);
    return TR_GetEntityIndex();
}

public bool:TraceRayDontHitPlayerAndWorld(entityhit, mask) {
    return entityhit>MaxClients
}

public bool:TraceRayFilter(ent, contents)
{
	return false;
}