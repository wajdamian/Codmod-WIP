#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Podrecznik Szpiega";
new const String:opis[] = "Posiadasz ubranie wroga, ciche kroki i jestes niewidoczny na radarze.";

new bool:ma_item[65];

Address g_aCanBeSpotted = view_as<Address>(892); //na windows 868

public Plugin:myinfo =
{
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
	SetEntProp(client, Prop_Send, "m_bSpotted", false);
	SetEntProp(client, Prop_Send, "m_bSpottedByMask", 0, 4, 0);
	SetEntProp(client, Prop_Send, "m_bSpottedByMask", 0, 4, 1);
	StoreToAddress(GetEntityAddress(client)+g_aCanBeSpotted, 0, NumberType_Int32);

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

public cod_item_disabled(client)
{
	ma_item[client] = false;
	StoreToAddress(GetEntityAddress(client)+g_aCanBeSpotted, 9, NumberType_Int32); 
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	if (ma_item[client])
	{
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
	return Plugin_Continue;
}