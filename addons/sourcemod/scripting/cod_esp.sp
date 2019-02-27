#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#define ADMIN_FLAG ADMFLAG_ROOT // flaga dla posiadacza admin esp po smierci

new bool:esp_gracza[65],
	Float:time_gracza[65];

new sprite_beam,
	sprite_halo;

public Plugin:myinfo =
{
	name = "Admin Esp",
	author = "Linux`",
	description = "Wallhack dla adminow",
	version = "1.0",
	url = "http://steamcommunity.com/id/linux2006"
};
public OnPluginStart()
{
	HookEvent("player_spawn", OdrodzenieGracza);
	HookEvent("player_death", SmiercGracza);
}
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("set_user_esp", UstawEsp);
	CreateNative("get_user_esp", PobierzEsp);
}
public OnMapStart()
{
	sprite_beam = PrecacheModel("sprites/laserbeam.vmt");
	sprite_halo = PrecacheModel("sprites/glow01.vmt");
}
public OnClientAuthorized(client)
{
	esp_gracza[client] = false;
	time_gracza[client] = 0.0;
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_PreThinkPost, PreThinkPost);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_PreThinkPost, PreThinkPost);
}
public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !esp_gracza[client])
		return Plugin_Continue;

	esp_gracza[client] = false;
	return Plugin_Continue;
}
public Action:SmiercGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !esp_gracza[client])
		return Plugin_Continue;

	esp_gracza[client] = false;
	return Plugin_Continue;
}
public Action:PreThinkPost(client)
{
	if(!IsValidClient(client))
		return Plugin_Continue;

	if(esp_gracza[client])
	{
		new Float:gametime = GetGameTime();
		if(gametime > time_gracza[client]+0.2)
		{
			if(IsPlayerAlive(client))
				StworzWallhack(client, client, 0);
			else
			{
				new target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
				if(target != -1 && IsValidClient(target))
					StworzWallhack(client, target, 0);
			}

			time_gracza[client] = gametime;
		}
	}
	if(!IsPlayerAlive(client))
	{
		static bool:oldbuttons[65];
		new buttons = GetClientButtons(client);	
		if(!oldbuttons[client] && buttons & IN_RELOAD)
		{
			if(GetUserFlagBits(client) & ADMIN_FLAG)
			{
				if(esp_gracza[client])
				{
					esp_gracza[client] = false;
				}
				else
				{
					esp_gracza[client] = true;
				}
			}

			oldbuttons[client] = true;
		}
		else if(oldbuttons[client] && !(buttons & IN_RELOAD))
			oldbuttons[client] = false;
	}

	return Plugin_Continue;
}
public Action:StworzWallhack(client, target, typ)
{
	new Float:torigin[3], Float:forigin[3];
	GetClientEyePosition(target, torigin);

	new Float:v_middle[3], Float:v_hitpoint[3], Float:v_bone_start[3], Float:v_bone_end[3], Float:offset_vector[3], Float:eye_level[3];
	new Float:distance, Float:distance_to_hitpoint, Float:scaled_bone_len, Float:scaled_bone_width, Float:width;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(typ && GetClientTeam(client) == GetClientTeam(i))
			continue;

		GetClientEyePosition(i, forigin);
		distance = GetVectorDistance(torigin, forigin);
		if(distance < 2040.0)
			width = (255.0-(distance/8.0))/3.0;
		else
			width = 1.0;

		new Handle:trace = TR_TraceRayFilterEx(torigin, forigin, MASK_SHOT, RayType_EndPoint, TraceEntityFilterPlayer, target);
		if(TR_DidHit(trace))
			TR_GetEndPosition(v_hitpoint, trace);

		CloseHandle(trace);
		subvec(forigin, torigin, v_middle);
		distance_to_hitpoint = GetVectorDistance(torigin, v_hitpoint, false);
		scaled_bone_len = distance_to_hitpoint / distance*50.0;
		scaled_bone_width = distance_to_hitpoint / distance*150.0;
		normalize(v_middle, offset_vector, distance_to_hitpoint - 10.0);
		copyvec(torigin, eye_level);
		addvec(offset_vector, eye_level);
		copyvec(offset_vector, v_bone_start);
		copyvec(offset_vector, v_bone_end);
		v_bone_end[2] -= scaled_bone_len;

		TE_SetupBeamPoints(torigin, forigin, sprite_beam, sprite_halo, 0, 0, 0.5, width, width, 0, 0.0, (GetClientTeam(i) == CS_TEAM_T)? {255, 0, 0, 128}: {0, 0, 255, 128}, 0);
		TE_SendToClient(client);

		TE_SetupBeamPoints(v_bone_start, v_bone_end, sprite_beam, sprite_halo, 0, 0, 0.5, scaled_bone_len, scaled_bone_width, 0, 0.0, {0, 255, 0, 128}, 0);
		TE_SendToClient(client);
	}

	return Plugin_Continue;
}
public bool:TraceEntityFilterPlayer(ent, contents, any:data)
{
	return data != ent;
}
public copyvec(Float:vec[3], Float:ret[3])
{
	ret[0] = vec[0];
	ret[1] = vec[1];
	ret[2] = vec[2];
}
public subvec(Float:vec1[3], Float:vec2[3], Float:ret[3])
{
	ret[0] = vec1[0]-vec2[0];
	ret[1] = vec1[1]-vec2[1];
	ret[2] = vec1[2]-vec2[2];
}
public addvec(Float:vec1[3], Float:vec2[3])
{
	vec1[0] += vec2[0];
	vec1[1] += vec2[1];
	vec1[2] += vec2[2];
}
public normalize(Float:vec[3], Float:ret[3], Float:multiplier)
{
	new Float:len = getveclen(vec);
	copyvec(vec, ret);
	ret[0] /= len;
	ret[1] /= len;
	ret[2] /= len;
	ret[0] *= multiplier;
	ret[1] *= multiplier;
	ret[2] *= multiplier;
}
public Float:getveclen(Float:vec[3])
{
	new Float:vecnull[3] = {0.0, 0.0, 0.0};
	new Float:len = GetVectorDistance(vec, vecnull);
	return len;
}
public UstawEsp(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		esp_gracza[client] = GetNativeCell(2)? true: false;

	return -1;
}
public PobierzEsp(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return esp_gracza[client];

	return -1;
}
public bool:IsValidClient(client)
{
	if(client >= 1 && client <= MaxClients && IsClientInGame(client))
		return true;

	return false;
}