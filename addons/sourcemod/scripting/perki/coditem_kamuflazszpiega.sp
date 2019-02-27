#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>
#include <cstrike>

new const String:nazwa[] = "Kamuflaz Szpiega";
new const String:opis[] = "Masz 1/LW szansy na odrodzenie się u przeciwnika i posiadasz ubranie wroga";

new CTZones[100], CTZonesSize, TZones[100], TZonesSize;

new bool:ma_item[65],
	wartosc_itemu[65];

public Plugin:myinfo =
{
	author = "de duk goos quak m8",
	description = "cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 4, 5);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
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

public OnMapStart()
{
	new ent = -1;  
	 	
	while ((ent = FindEntityByClassname(ent, "info_player_counterterrorist")) != -1)  
	{
		CTZones[CTZonesSize] = ent;
		CTZonesSize++;
	}

	ent = -1;
	while ((ent = FindEntityByClassname(ent, "info_player_terrorist")) != -1)  
	{
		TZones[TZonesSize] = ent;
		TZonesSize++;
	}
}


public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dnt)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_item[client])
		return;
		
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
	
	new x = wartosc_itemu[client];
	new Luck = GetRandomInt(1, x);
	
	if(Luck == 1)
	{
		new Float:Origin[3];
		if(GetClientTeam(client) == CS_TEAM_CT)
			GetEntPropVector(TZones[GetRandomInt(0, TZonesSize-1)], Prop_Data, "m_vecOrigin", Origin);
			
		else if(GetClientTeam(client) == CS_TEAM_T)
			GetEntPropVector(CTZones[GetRandomInt(0, CTZonesSize-1)], Prop_Data, "m_vecOrigin", Origin);
			
		else
			return;
			
		TeleportEntity(client, Origin, NULL_VECTOR, NULL_VECTOR);
	}
	
}