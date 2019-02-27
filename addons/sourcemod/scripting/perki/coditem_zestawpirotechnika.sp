#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>
#include <cstrike>

new const String:nazwa[] = "Zestaw Pirotechnika";
new const String:opis[] = "Rozbrajasz i podkladasz bombe w sekunde";

new bool:ma_item[65];

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
	HookEvent("bomb_begindefuse", Event_BeginDefuseOrPlant);
	HookEvent("bomb_beginplant", Event_BeginDefuseOrPlant);
}
public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public Action:Event_BeginDefuseOrPlant(Handle:event, String:name[], bool:dontBroadcast)
{	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!ma_item[client])
		return Plugin_Continue;
	
	new userid = GetEventInt(event, "userid");
	CreateTimer(1.0, timer_delay, userid, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action:timer_delay(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);

	if(client != 0)
	{
		if (IsPlayerAlive(client) && ma_item[client])
		{
			new c4pre = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			new String:classname[30];
			GetEntityClassname(c4pre, classname, sizeof(classname));
			
			if(GetClientButtons(client) & IN_ATTACK && StrEqual(classname, "weapon_c4", false))
			{
				SetEntPropFloat(c4pre, Prop_Send, "m_fArmedTime", GetGameTime());
			}
			else if(GetClientButtons(client) & IN_USE)
			{
				new c4post = FindEntityByClassname(MaxClients+1, "planted_c4");
				if(c4post != -1)
				{
					SetEntPropFloat(c4post, Prop_Send, "m_flDefuseCountDown", 0.0);
					SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0);
				}
			}
		}
	}
}