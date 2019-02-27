#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <codmod>

new const String:nazwa[] = "Wsparcie Ogniowe";
new const String:opis[] = "Posiada 3 rakiety, zadające [55 + 0.5 * INT] obrażeń; Cooldown: 4sek.";
new const String:bronie[] = "#weapon_mp7#weapon_tec9";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 0;
new const wytrzymalosc = 10;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];
new bool:skillReady[65];
ilosc_rakiet_gracza[65];

new sprite_explosion;
public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Wsparcie ogniowe",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	HookEvent("player_spawn", OdrodzenieGracza);
}
public OnMapStart()
{
	PrecacheModel("models/props/de_vertigo/construction_safetyribbon_01.mdl");
	sprite_explosion = PrecacheModel("materials/sprites/blueflare1.vmt");
	PrecacheSound("weapons/hegrenade/explode5.wav");
}
public cod_class_enabled(client)
{
	ma_klase[client] = true;
	skillReady[client] = true;
	ilosc_rakiet_gracza[client] = 3;
}
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}
public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
		
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(StrEqual(weapon, "weapon_mp7") && (damagetype & (DMG_BULLET)) && (GetClientButtons(attacker) & IN_ATTACK))
	{
		damage+=5;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
public cod_class_skill_used(client)
{
	if (skillReady[client] && ma_klase[client])
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
	if(!IsValidClient(attacker) || !ma_klase[attacker])
	{
		AcceptEntityInput(ent, "Kill");
		return Plugin_Continue;
	}
	if(IsValidClient(client) && GetClientTeam(attacker) == GetClientTeam(client))
		return Plugin_Continue;

	new Float:forigin[3], Float:iorigin[3];
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", forigin);

	new damage = 55+RoundFloat(cod_get_user_maks_intelligence(attacker)*0.5);
	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(GetClientTeam(attacker) == GetClientTeam(i))
			continue;
		
		if(cod_get_user_item(i) == cod_get_itemid("Tarcza SWAT"))
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
	if(!IsValidClient(client) || !ma_klase[client])
		return Plugin_Continue;

	ilosc_rakiet_gracza[client] = 3;
	return Plugin_Continue;
}