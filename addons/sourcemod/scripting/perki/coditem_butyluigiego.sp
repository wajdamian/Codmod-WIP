#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Buty Luigiego";
new const String:opis[] = "AutoBH";

new bool:ma_item[65];

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
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapons)
{
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	if(!IsPlayerAlive(client))
		return Plugin_Continue;

	if(buttons & IN_JUMP)
	{
		if(!(GetEntityFlags(client) & (FL_WATERJUMP | FL_ONGROUND)))
			buttons &= ~IN_JUMP;
	}

	return Plugin_Continue;
}