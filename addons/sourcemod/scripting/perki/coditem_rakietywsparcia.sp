#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Rakiety wsparcia";
new const String:opis[] = "Posiadasz 2 rakiety 50+int dmg.";

new bool:ma_item[65],
	bool:skillReady[65];
	
new ilosc_rakiet_gracza[65];
new sprite_explosion;

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Cod perk",
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
	PrecacheModel("models/props/de_vertigo/construction_safetyribbon_01.mdl");
	sprite_explosion = PrecacheModel("materials/sprites/blueflare1.vmt");
	PrecacheSound("weapons/hegrenade/explode5.wav");
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	skillReady[client] = true;
	ilosc_rakiet_gracza[client] = 2;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public cod_item_used(client)
{
	if (skillReady[client] && ma_item[client])
	{
		if(!ilosc_rakiet_gracza[client])
			PrintToChat(client, "Wykorzystałeś wszystkie rakiety w tym życiu!");
		else
		{
			new ent = CreateEntityByName("hegrenade_projectile");
			if(ent != -1)
			{
				new Float:forigin[3];
				GetClientEyePosition(client, forigin);

				new Float:fangles[3];
				GetClientEyeAngles(client, fangles);

				new Float:iorigin[3], Float:iangles[3], Float:ivector[3];
				TR_TraceRayFilter(forigin, fangles, MASK_SOLID, RayType_Infinite, TraceRayFilter, ent);
				TR_GetEndPosition(iorigin);
				DispatchSpawn(ent);
				ActivateEntity(ent);
				SetEntityModel(ent, "models/props/de_vertigo/construction_safetyribbon_01.mdl");
				SetEntityMoveType(ent, MOVETYPE_STEP);
				SetEntityGravity(ent, 0.1);
				MakeVectorFromPoints(forigin, iorigin, ivector);
				NormalizeVector(ivector, ivector);
				ScaleVector(ivector, 1000.0);
				GetVectorAngles(ivector, iangles);
				TeleportEntity(ent, forigin, iangles, ivector);
				SetEntProp(ent, Prop_Send, "m_usSolidFlags", 12);
				SetEntProp(ent, Prop_Data, "m_nSolidType", 6);
				SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
				SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
				SDKHook(ent, SDKHook_StartTouchPost, DotykRakiety);

				ilosc_rakiet_gracza[client] --;
				skillReady[client] = false;
				CreateTimer(4.0, skillRenewal, client, TIMER_FLAG_NO_MAPCHANGE)
			}
		}
	} else PrintToChat(client, "Nie możesz jeszcze użyć tej umiejętności!");
}
public Action:skillRenewal(Handle:Timer, any:client)
{
	skillReady[client]=true;
	if(ilosc_rakiet_gracza[client]>0)
		PrintToChat(client, "Możesz odpalić kolejną rakietę!");
	else
		PrintToChat(client, "Wykorzystałeś wszystkie rakiety w tym życiu!");
}
public Action:DotykRakiety(ent, client)
{
	if(!IsValidEntity(ent))
		return Plugin_Continue;

	new attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(attacker) || !ma_item[attacker])
	{
		AcceptEntityInput(ent, "Kill");
		return Plugin_Continue;
	}
	if(IsValidClient(client) && GetClientTeam(attacker) == GetClientTeam(client))
		return Plugin_Continue;

	new Float:forigin[3], Float:iorigin[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", forigin);

	new damage = 50+cod_get_user_maks_intelligence(attacker);
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(GetClientTeam(attacker) == GetClientTeam(i))
			continue;

		GetClientEyePosition(i, iorigin);
		if(GetVectorDistance(forigin, iorigin) <= 100.0)
		{
			if(cod_get_user_class(i) == cod_get_classid("Obronca"))
				continue;

			cod_inflict_damage(i, attacker, damage);
		}
	}

	EmitSoundToAll("weapons/hegrenade/explode5.wav", ent, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
	TE_SetupExplosion(forigin, sprite_explosion, 10.0, 1, 0, 100, 100);
	TE_SendToAll();

	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
public bool:TraceRayFilter(ent, contents)
{
	return false;
}
public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	ilosc_rakiet_gracza[client] = 2;
	return Plugin_Continue;
}