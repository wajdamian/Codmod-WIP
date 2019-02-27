#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Teleport";
new const String:opis[] = "Teleportujesz sie do wczesniej zapisanego miejsca";

new bool:ma_item[65],
	bool:canUse[65],
	bool:isSaved[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "poJawIaM siE I ZniKAm",
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
	isSaved[client] = false;
}

public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public cod_item_used(client)
{
	if (!ma_item[client] || !canUse[client])
		return;
	
	new Float:tpVec[3], Float:tpAng[3];
	if (!isSaved[client])
	{
		GetClientAbsOrigin(client, tpVec);
		GetClientAbsAngles(client, tpAng);
		isSaved[client] = true;
	}
	else
	{
		TeleportEntity(client, tpVec, tpAng, NULL_VECTOR);
		canUse[client] = false;
	}
	return;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;
	
	canUse[client] = true;
	isSaved[client] = false;
	return Plugin_Continue;
}