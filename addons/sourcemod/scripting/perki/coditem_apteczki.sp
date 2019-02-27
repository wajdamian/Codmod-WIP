#include <sourcemod>
#include <sdktools>
#include <codmod>

new const String:nazwa[] = "Apteczki";
new const String:opis[] = "Posiadasz 2 apteczki 5+int hp/s";

new bool:ma_item[65],
ilosc_apteczek[65];

new sprite_beam,
	sprite_halo;

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
}
public OnMapStart()
{
	PrecacheModel("models/codmod/apteczka/apteczka.mdl");
	sprite_beam = PrecacheModel("sprites/laserbeam.vmt");
	sprite_halo = PrecacheModel("sprites/glow01.vmt");
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	ilosc_apteczek[client] = 2;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public cod_item_used(client)
{
	if(!ilosc_apteczek[client])
		PrintToChat(client, "Nie masz juz wiecej apteczek!");
	else
	{
		new ent = CreateEntityByName("hegrenade_projectile");
		if(ent != -1)
		{
			new Float:forigin[3];
			GetClientEyePosition(client, forigin);

			new Float:fangles[3];
			GetClientEyeAngles(client, fangles);

			new Float:iangles[3] = {0.0, 0.0, 0.0};
			iangles[1] = fangles[1];

			DispatchSpawn(ent);
			ActivateEntity(ent);
			SetEntityModel(ent, "models/codmod/apteczka/apteczka.mdl");
			SetEntityMoveType(ent, MOVETYPE_STEP);
			TeleportEntity(ent, forigin, iangles, NULL_VECTOR);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 12);
			SetEntProp(ent, Prop_Data, "m_nSolidType", 6);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
			SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);

			new ref = EntIndexToEntRef(ent);
			CreateTimer(1.0, ThinkApteczka, ref, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(8.0, ThinkEndApteczka, ref, TIMER_FLAG_NO_MAPCHANGE);

			ilosc_apteczek[client] --;
		}
	}
}
public Action:ThinkApteczka(Handle:timer, any:ref)
{
	new ent = EntRefToEntIndex(ref);
	if (ent == -1 || !IsValidEntity(ent))
		return Plugin_Continue;

	new client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(client) || !ma_item[client])
	{
		AcceptEntityInput(ent, "Kill");
		return Plugin_Continue;
	}

	new Float:forigin[3], Float:iorigin[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", forigin);
	
	new regeneracja = 5+cod_get_user_maks_intelligence(client);
	new health, maks_health;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(GetClientTeam(client) != GetClientTeam(i))
			continue;

		GetClientEyePosition(i, iorigin);
		if(GetVectorDistance(forigin, iorigin) <= 150.0)
		{
			health = GetClientHealth(i);
			maks_health = cod_get_user_maks_health(i);
			SetEntData(i, FindDataMapInfo(i, "m_iHealth"), (health+regeneracja > maks_health)? maks_health: health+regeneracja);
		}
	}

	TE_SetupBeamRingPoint(forigin, 20.0, 100.0, sprite_beam, sprite_halo, 0, 10, 0.6, 6.0, 0.0, {200, 100, 200, 128}, 10, 0);
	TE_SendToAll();

	CreateTimer(1.0, ThinkApteczka, ent, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action:ThinkEndApteczka(Handle:timer, any:ref)
{
	new ent = EntRefToEntIndex(ref);
	if (ent == -1 || !IsValidEntity(ent))
		return Plugin_Continue;

	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	ilosc_apteczek[client] = 2;
	return Plugin_Continue;
}