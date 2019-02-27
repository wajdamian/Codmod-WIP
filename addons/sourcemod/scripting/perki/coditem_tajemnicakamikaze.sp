#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Tajemnica Kamikadze";
new const String:opis[] = "Przez 3s po uzyciu jestes niesmiertelny, po czym wybuchasz zabijajac wszystkich w promieniu 350u";

new bool:ma_item[65],
	bool:canUse[65],
	bool:isInvincible[65];
	
new sprite_explosion;

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "herbatki bym sie napil",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
	HookEvent("player_spawn", OdrodzenieGracza);
}
public OnMapStart()
{
	sprite_explosion = PrecacheModel("materials/sprites/blueflare1.vmt");
	PrecacheSound("weapons/hegrenade/explode5.wav");
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
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public cod_item_used(client)
{
	if (ma_item[client] && IsPlayerAlive(client) && canUse[client])
	{
		canUse[client] = false;
		isInvincible[client] = true;
		new serial = GetClientSerial(client);
		CreateTimer(3.0, BoomBoom, serial, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_item[client])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	if(!isInvincible[client])
		return Plugin_Continue;

	damage = 0.0;
	return Plugin_Changed;
}

public Action:BoomBoom(Handle:Timer, any:serial)
{
	new client = GetClientFromSerial(serial);
	if (!ma_item[client] || !IsValidClient(client))
		return Plugin_Continue;
		
	if (!IsPlayerAlive(client))
	{
		isInvincible[client] = false;
		return Plugin_Continue;
	}
	new Float:forigin[3], Float:iorigin[3];
	GetClientEyePosition(client, forigin);
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(GetClientTeam(client) == GetClientTeam(i))
			continue;

		GetClientEyePosition(i, iorigin);
		if(GetVectorDistance(forigin, iorigin) <= 350.0)
		{
			cod_inflict_damage(i, client, 999);
		}
	}
	EmitSoundToAll("weapons/hegrenade/explode5.wav", client, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
	TE_SetupExplosion(forigin, sprite_explosion, 10.0, 1, 0, 350, 100);
	TE_SendToAll();
	cod_inflict_damage(client, client, 999);
	isInvincible[client] = false;
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;
	
	canUse[client] = true;
	return Plugin_Continue;
}