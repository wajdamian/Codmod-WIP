#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Wybuchowe Naboje";
new const String:opis[] = "Po zabiciu przeciwnik wybucha, zadając 40% swojego max hp w zasięgu 300u.";

new bool:ma_item[65];
new sprite_explosion;

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnMapStart()
{
	sprite_explosion = PrecacheModel("materials/sprites/blueflare1.vmt");
	PrecacheSound("weapons/hegrenade/explode5.wav");
}
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
	HookEvent("player_death", SmiercGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (!IsValidClient(client) || !IsValidClient(attacker) || !ma_item[attacker])
		return Plugin_Continue;
	
	new Float:forigin[3], Float:iorigin[3];
	GetClientEyePosition(client, forigin);
	new damage = RoundToNearest(cod_get_user_maks_health(attacker) * 0.4);
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(GetClientTeam(attacker) == GetClientTeam(i))
			continue;

		GetClientEyePosition(i, iorigin);
		if(GetVectorDistance(forigin, iorigin) <= 300.0)
		{
			cod_inflict_damage(i, attacker, damage);
			EmitSoundToAll("weapons/hegrenade/explode5.wav", client, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
			TE_SetupExplosion(iorigin, sprite_explosion, 10.0, 1, 0, 300, 100);
			TE_SendToAll();
		}
	}
	return Plugin_Continue;
}