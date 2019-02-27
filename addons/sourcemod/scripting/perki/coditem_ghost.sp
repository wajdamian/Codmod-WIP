#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Ghost";
new const String:opis[] = "Przenikasz przez ściany przez 3s. Użyj ponownie, by wyłączyć.";

new bool:ma_item[65];
new Float:startPos[65][3];
new Float:startPosA[65][3];	
new Float:endPos[65][3];

new bool:canUse[65];
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
	HookEvent("player_spawn", OdrodzenieGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	canUse[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public cod_item_used(client)
{
	if (ma_item[client] && canUse[client])
	{
		if (GetEntityMoveType(client) != MOVETYPE_NOCLIP)
		{
			GetClientEyePosition(client, startPos[client]);
			GetClientEyeAngles(client, startPosA[client]);
			SetEntityMoveType(client, MOVETYPE_NOCLIP);
			CreateTimer(3.0, DisableNoclip, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			canUse[client] = false;
			GetClientEyePosition(client, endPos[client]);
			if (!IsPlayerStuck(client) || TR_PointOutsideWorld(endPos[client]))
				TeleportEntity(client, startPos[client], startPosA[client], NULL_VECTOR);
		}
	}
}

public Action:DisableNoclip(Handle:Timer, any:client)
{
	if(client<1||!IsClientInGame(client)||!IsPlayerAlive(client))
		return;
	if (GetEntityMoveType(client) != MOVETYPE_NOCLIP)
    {
		return;
	}
	else
    {
		SetEntityMoveType(client, MOVETYPE_WALK);
		canUse[client] = false;
		GetClientEyePosition(client, endPos[client]);
		if (!IsPlayerStuck(client) || TR_PointOutsideWorld(endPos[client]))
			TeleportEntity(client, startPos[client], startPosA[client], NULL_VECTOR);
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

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || ma_item[client])
		return Plugin_Continue;
	
	canUse[client] = true;
	return Plugin_Continue;
}