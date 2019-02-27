#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <codmod>
#include <cstrike>

new const String:nazwa[] = "Tajemnica Medyka";
new const String:opis[] = "Możesz wskrzesić do trzech swoich poległych towarzyszy na rundę.";

new bool:ma_item[MAXPLAYERS+1];
new ilosc_wskrzeszen[MAXPLAYERS+1];
new Float:dOrigin[MAXPLAYERS+1][3];

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
	HookEvent("player_death", SmiercGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	ilosc_wskrzeszen[client] = 3;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public cod_item_used(client)
{
	if (!ma_item[client] || !IsValidClient(client) || !IsPlayerAlive(client))
	return;
	
	if (ilosc_wskrzeszen[client] > 0)
	{
		new Float:forigin[3];
		GetClientEyePosition(client, forigin);
		
		new Float:fangles[3];
		GetClientEyeAngles(client, fangles);

		new Float:iangles[3] = {0.0, 0.0, 0.0};
		iangles[1] = fangles[1];
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i) || IsPlayerAlive(i))
				continue;

			if(GetClientTeam(client) != GetClientTeam(i))
				continue;
			
			if(GetVectorDistance(forigin, dOrigin[i]) <= 100.0)
			{
				CS_RespawnPlayer(i);
				ilosc_wskrzeszen[client]--;
				break;
			}
		}
	}
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return Plugin_Continue;

	GetClientEyePosition(client, dOrigin[client]);
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
	{
		dOrigin[client][2] = -27090.5;
		return Plugin_Continue;
	}
	
	ilosc_wskrzeszen[client] = 3;
	dOrigin[client][2] = -27090.5;
	return Plugin_Continue;
}