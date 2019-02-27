#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <codmod>
#include <cstrike>

new const String:nazwa[] = "Medyk";
new const String:opis[] = "Ma dwie apteczki leczace obszarowo 5+0.2int hp na sekunde przez 5 sec, na +use moze wskrzesic 4 graczy, +5dmg glock";
new const String:bronie[] = "#weapon_mp9#weapon_glock";
new const inteligencja = 0;
new const zdrowie = 20;
new const obrazenia = 0;
new const wytrzymalosc = 20;
new const kondycja = 15;
new const flagi = 0;

new Float:dOrigin[MAXPLAYERS+1][3];
new bool:ma_klase[MAXPLAYERS+1],
ilosc_apteczek_gracza[MAXPLAYERS+1];
ilosc_odrodzen_gracza[MAXPLAYERS+1];

new sprite_beam,
	sprite_halo;

	
	
public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Medyk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};

public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	HookEvent("player_spawn", OdrodzenieGracza);
	HookEvent("player_death", SmiercGracza);
}
public OnMapStart()
{
	PrecacheModel("models/codmod/apteczka/apteczka.mdl");
	sprite_beam = PrecacheModel("sprites/laserbeam.vmt");
	sprite_halo = PrecacheModel("sprites/glow01.vmt");
}
public cod_class_enabled(client)
{
	ma_klase[client] = true;
	ilosc_apteczek_gracza[client] = 2;
	ilosc_odrodzen_gracza[client] = 4;
}
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return Plugin_Continue;

	GetClientEyePosition(client, dOrigin[client]);
	return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!ma_klase[client] || !IsValidClient(client) || !IsPlayerAlive(client))
	return Plugin_Continue;
	
	if ((GetClientButtons(client) & IN_USE) && ilosc_odrodzen_gracza[client] > 0)
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
				ilosc_odrodzen_gracza[client]--;
				break;
			}
		}
	}
	return Plugin_Continue;
}

public cod_class_skill_used(client)
{
	if(!ilosc_apteczek_gracza[client])
		PrintToChat(client, "Wykorzystales juz moc swojej klasy w tym zyciu!");
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

			ilosc_apteczek_gracza[client] --;
		}
	}
}
public Action:ThinkApteczka(Handle:timer, any:ref)
{
	new ent = EntRefToEntIndex(ref);
	if (ent == -1 || !IsValidEntity(ent))
		return Plugin_Continue;

	new client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(client) || !ma_klase[client])
	{
		AcceptEntityInput(ent, "Kill");
		return Plugin_Continue;
	}

	new Float:forigin[3], Float:iorigin[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", forigin);
	
	new regeneracja = 5+RoundFloat(cod_get_user_maks_intelligence(client)*0.5);
	new health, maks_health;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(GetClientTeam(client) != GetClientTeam(i))
			continue;

		GetClientEyePosition(i, iorigin);
		if(GetVectorDistance(forigin, iorigin) <= 400.0)
		{
			health = GetClientHealth(i);
			maks_health = cod_get_user_maks_health(i);
			SetEntData(i, FindDataMapInfo(i, "m_iHealth"), (health+regeneracja > maks_health)? maks_health: health+regeneracja);
		}
	}

	TE_SetupBeamRingPoint(forigin, 20.0, 200.0, sprite_beam, sprite_halo, 0, 10, 0.6, 6.0, 0.0, {0, 255, 0, 128}, 10, 0);
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
	if(!IsValidClient(client) || !ma_klase[client])
	{
		dOrigin[client][2] = -27090.5;
		return Plugin_Continue;
	}
	
	ilosc_apteczek_gracza[client] = 2;
	ilosc_odrodzen_gracza[client] = 4;
	dOrigin[client][2]= -27090.5;
	return Plugin_Continue;
}