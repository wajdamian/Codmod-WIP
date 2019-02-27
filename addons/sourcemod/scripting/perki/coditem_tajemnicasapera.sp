#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <codmod>


new const String:nazwa[] = "Tajemnica Sapera";
new const String:opis[] = "Posiadasz 3 miny 100+int dmg";

new bool:ma_item[65],
	ilosc_min_gracza[65];
	
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
}
public OnMapStart()
{
	PrecacheModel("models/props_junk/metal_paintcan001a.mdl");
	sprite_explosion = PrecacheModel("materials/sprites/blueflare1.vmt");
	PrecacheSound("weapons/hegrenade/explode5.wav");
}
public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
	ilosc_min_gracza[client] = 3;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public cod_item_used(client)
{
	if(!ilosc_min_gracza[client])
		PrintToChat(client, "Wykorzystales juz wszystkie miny!");
	else
	{
		new ent = CreateEntityByName("hegrenade_projectile");
		if(ent != -1)
		{
			new Float:forigin[3];
			GetClientEyePosition(client, forigin);

			new Float:fangles[3];
			GetClientEyeAngles(client, fangles);

			new Float:iangles[3];
			iangles[1] = fangles[1];

			DispatchSpawn(ent);
			ActivateEntity(ent);
			SetEntityModel(ent, "models/props_junk/metal_paintcan001a.mdl");
			SetEntityMoveType(ent, MOVETYPE_STEP);
			TeleportEntity(ent, forigin, iangles, NULL_VECTOR);
			SetEntProp(ent, Prop_Send, "m_usSolidFlags", 12);
			SetEntProp(ent, Prop_Data, "m_nSolidType", 6);
			SetEntProp(ent, Prop_Send, "m_CollisionGroup", 1);
			SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client);
			SetEntityRenderMode(ent, RENDER_TRANSALPHA);
			SetEntityRenderColor(ent, 0, 0, 0, 25);
			SDKHook(ent, SDKHook_StartTouchPost, DotykMiny);

			ilosc_min_gracza[client] --;
		}
	}
}
public Action:DotykMiny(ent, client)
{
	if(!IsValidEntity(ent))
		return Plugin_Continue;

	new attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(attacker) || !ma_item[attacker])
	{
		AcceptEntityInput(ent, "Kill");
		return Plugin_Continue;
	}
	if(!IsValidClient(client) || IsValidClient(client) && GetClientTeam(attacker) == GetClientTeam(client))
		return Plugin_Continue;

	new Float:forigin[3], Float:iorigin[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", forigin);

	new damage = 100+cod_get_user_maks_intelligence(attacker);
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(GetClientTeam(attacker) == GetClientTeam(i))
			continue;

		GetClientEyePosition(i, iorigin);
		if(GetVectorDistance(forigin, iorigin) <= 250.0)
		{
			if(cod_get_user_class(i) == cod_get_classid("Obronca"))
				continue;
			
			if(cod_get_user_item(i) == cod_get_itemid("Zwrot do nadawcy"))
			{
				cod_inflict_damage(attacker, i, damage);
				continue;
			}
			cod_inflict_damage(i, attacker, damage);
		}
	}

	EmitSoundToAll("weapons/hegrenade/explode5.wav", ent, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
	TE_SetupExplosion(forigin, sprite_explosion, 10.0, 1, 0, 250, 100);
	TE_SendToAll();

	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	ilosc_min_gracza[client] = 3;
	return Plugin_Continue;
}