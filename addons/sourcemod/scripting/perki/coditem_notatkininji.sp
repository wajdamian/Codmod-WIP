#include <sourcemod>
#include <sdktools>
#include <codmod>

new const String:nazwa[] = "Notatki Ninji";
new const String:opis[] = "Posiadasz dodatkowy skok w powietrzu";

new bool:ma_item[65];
public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu"
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

	static bool:oldbuttons[65];
	if(!oldbuttons[client] && buttons & IN_JUMP)
	{
		static bool:multijump[65];
		new flags = GetEntityFlags(client);
		if(!(flags & FL_ONGROUND) && !multijump[client])
		{
			new Float:forigin[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", forigin);
			forigin[2] += 250.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, forigin);
			multijump[client] = true;
		}
		else if(flags & FL_ONGROUND)
			multijump[client] = false;

		oldbuttons[client] = true;
	}
	else if(oldbuttons[client] && !(buttons & IN_JUMP))
		oldbuttons[client] = false;

	return Plugin_Continue;
}