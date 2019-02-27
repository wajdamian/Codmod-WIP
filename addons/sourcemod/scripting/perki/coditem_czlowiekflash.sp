#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "Człowiek flash";
new const String:opis[] = "Oślepiasz przeciwników na odległość 500u (co 10 sekund)";

new bool:ma_item[65];
float g_fLastUsed[65] = { 0.0 };
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;

public Plugin:myinfo =
{
	name = nazwa,
	author = ".nbd",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/geneccc"
};

public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
}

public OnMapStart()
{
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/halo.vmt");
}

public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
	g_fLastUsed[client] = 0.0;
}

public cod_item_disabled(client)
{
	ma_item[client] = false;
	g_fLastUsed[client] = 0.0;
}


public cod_item_used(client)
{
	if(!IsPlayerAlive(client))
		return;

	if(GetGameTime() - g_fLastUsed[client] < 10.0)
	{
		PrintToChat(client, "Itemu możesz użyć dopiero za %.2fs", GetGameTime() - g_fLastUsed[client]);
		return;
	}

	float fOrigin[3];
	GetClientAbsOrigin(client, fOrigin);

	fOrigin[2] += 10;
	TE_SetupBeamRingPoint(fOrigin, 20.0, 400.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.6, 10.0, 0.5, {0, 200, 0, 255}, 10, 0);
	TE_SendToAll();
	fOrigin[2] -= 10;

	int iTeam = GetClientTeam(client);

	float fTargetOrigin[3];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && iTeam != GetClientTeam(i))
		{
			GetClientAbsOrigin(i, fTargetOrigin);
			if(GetVectorDistance(fTargetOrigin, fOrigin) <= 650.0)
			{
				cod_perform_blind(i, 2500, 255, 255, 255, 255);
			}
		}
	}
	g_fLastUsed[client] = GetGameTime();
}