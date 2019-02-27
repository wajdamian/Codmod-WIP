#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Narzedzia Demolitionsa";
new const String:opis[] = "Dostajesz ladunek wybuchowy który możesz wysadzić (70+0.5*int dmg)";

new bool:ma_item[65],	
	ilosc_ladunkow_gracza[65],
	podlozony_ladunek_gracza[65];
	
new sprite_explosion;

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
	HookEvent("player_death", SmiercGracza);
}
public OnMapStart()
{
	PrecacheModel("models/props/cs_office/radio.mdl");
	sprite_explosion = PrecacheModel("materials/sprites/blueflare1.vmt");
	PrecacheSound("weapons/hegrenade/explode5.wav");
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	ilosc_ladunkow_gracza[client] = 1;
}

public cod_item_disabled(client)
{
	ma_item[client] = false;
	StopLadunek(client);
}

public cod_item_used(client)
{
	if(podlozony_ladunek_gracza[client] && IsValidEntity(podlozony_ladunek_gracza[client]))
	{
		new Float:forigin[3], Float:iorigin[3];
		GetEntPropVector(podlozony_ladunek_gracza[client], Prop_Send, "m_vecOrigin", forigin);

		new damage = 40+RoundFloat(cod_get_user_maks_intelligence(client)*0.5);
		for(new i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			if(GetClientTeam(client) == GetClientTeam(i))
				continue;

			GetClientEyePosition(i, iorigin);
			if(GetVectorDistance(forigin, iorigin) <= 100.0)
			{
				if(cod_get_user_class(i) == cod_get_classid("Obronca"))
					continue;

				cod_inflict_damage(i, client, damage);
			}
		}

		EmitSoundToAll("weapons/hegrenade/explode5.wav", podlozony_ladunek_gracza[client], SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
		TE_SetupExplosion(forigin, sprite_explosion, 10.0, 1, 0, 100, 100);
		TE_SendToAll();

		AcceptEntityInput(podlozony_ladunek_gracza[client], "Kill");
		podlozony_ladunek_gracza[client] = 0;
	}
	else if(!ilosc_ladunkow_gracza[client])
		PrintToChat(client, "Wykorzystales juz ladunek!");
	else
	{
		podlozony_ladunek_gracza[client] = CreateEntityByName("hegrenade_projectile");
		if(podlozony_ladunek_gracza[client] != -1)
		{
			new Float:forigin[3];
			GetClientEyePosition(client, forigin);

			new Float:fangles[3];
			GetClientEyeAngles(client, fangles);

			new Float:iangles[3] = {0.0, 0.0, 0.0};
			iangles[1] = fangles[1];

			DispatchSpawn(podlozony_ladunek_gracza[client]);
			ActivateEntity(podlozony_ladunek_gracza[client]);
			SetEntityModel(podlozony_ladunek_gracza[client], "models/props/cs_office/radio.mdl");
			SetEntityMoveType(podlozony_ladunek_gracza[client], MOVETYPE_STEP);
			TeleportEntity(podlozony_ladunek_gracza[client], forigin, iangles, NULL_VECTOR);
			SetEntProp(podlozony_ladunek_gracza[client], Prop_Send, "m_usSolidFlags", 12);
			SetEntProp(podlozony_ladunek_gracza[client], Prop_Data, "m_nSolidType", 6);
			SetEntProp(podlozony_ladunek_gracza[client], Prop_Send, "m_CollisionGroup", 1);

			ilosc_ladunkow_gracza[client] --;
		}
	}
}

public Action:StopLadunek(client)
{
	if(podlozony_ladunek_gracza[client])
	{
		if(IsValidEntity(podlozony_ladunek_gracza[client]))
			AcceptEntityInput(podlozony_ladunek_gracza[client], "Kill");

		podlozony_ladunek_gracza[client] = 0;
	}

	return Plugin_Continue;
}
public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	StopLadunek(client);
	ilosc_ladunkow_gracza[client] = 1;

	return Plugin_Continue;
}
public Action:SmiercGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	StopLadunek(client);
	return Plugin_Continue;
}