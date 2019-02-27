#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Chimera";
new const String:opis[] = "Ma 2 pulapki (50+int dmg) trujace obszarowo (10dmg na 3sec), regeneruje 5hp co 10s";
new const String:bronie[] = "#weapon_galilar#weapon_glock#weapon_flashbang#weapon_smokegrenade#weapon_hegrenade#weapon_molotov";
new const inteligencja = 5;
new const zdrowie = 5;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];
new pulapkiGracza[65];
new g_iTimerCount[65];
new sprite_explosion;

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Chimera",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
}

public OnMapStart()
{
	PrecacheModel("models/props_junk/metal_paintcan001a.mdl");
	sprite_explosion = PrecacheModel("materials/sprites/yellowflare.vmt");
	PrecacheSound("weapons/sg556/sg556_boltback.wav");
}

public OnClientPutInServer(client)
{
	HookEvent("player_spawn", OdrodzenieGracza);
}

public cod_class_enabled(client)
{
	ma_klase[client] = true;
	pulapkiGracza[client] = 2;
	CreateTimer(10.0, Leczenie, client, TIMER_REPEAT);
} 
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public cod_class_skill_used(client)
{
	if(!pulapkiGracza[client])
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

			pulapkiGracza[client] --;
		}
	}
}

public Action:DotykMiny(ent, client)
{
	if(!IsValidEntity(ent))
		return Plugin_Continue;

	new attacker = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(attacker) || !ma_klase[attacker])
	{
		AcceptEntityInput(ent, "Kill");
		return Plugin_Continue;
	}
	if(!IsValidClient(client) || IsValidClient(client) && GetClientTeam(attacker) == GetClientTeam(client))
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
			
		if(cod_get_user_item(i) == cod_get_itemid("Tarcza SWAT"))
			continue;
			
		GetClientEyePosition(i, iorigin);
		iorigin[2] -= 60;
		if(GetVectorDistance(forigin, iorigin) <= 25.0)
		{
			cod_inflict_damage(i, attacker, damage);
		}
		
		if (GetVectorDistance(forigin, iorigin) <=100.0)
		{
			DataPack hData;
			CreateDataTimer(1.0, Otrucie, hData, TIMER_REPEAT);
			WritePackCell(hData, GetClientSerial(i));
			WritePackCell(hData, GetClientSerial(attacker));
			g_iTimerCount[client] = 1;
		}
	}
	
	EmitSoundToAll("weapons/sg556/sg556_boltback.wav", ent, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
	TE_SetupExplosion(forigin, sprite_explosion, 10.0, 1, 0, 250, 100);
	TE_SendToAll();

	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

public Action:Otrucie(Handle:Timer, Handle:hData)
{	
	if (Timer == INVALID_HANDLE)
		return Plugin_Stop;
	ResetPack(hData);
	new victim = GetClientFromSerial(ReadPackCell(hData));
	new attacker = GetClientFromSerial(ReadPackCell(hData));

	if (!IsPlayerAlive(victim) || !IsClientInGame(victim) || !IsClientInGame(attacker) || g_iTimerCount[victim] >= 3)
	{
		g_iTimerCount[victim] = 1;
		return Plugin_Stop;
	}

	g_iTimerCount[victim]++;
	cod_inflict_damage(victim, attacker, 10); 
	return Plugin_Continue;
}

public Action:Leczenie(Handle:Timer, any:client)
{
	if (!ma_klase[client] || !IsPlayerAlive(client) || !IsClientInGame(client) || !IsValidClient(client))
	{
		return Plugin_Stop;
	}
	SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (GetClientHealth(client)+5 < cod_get_user_maks_health(client))? GetClientHealth(client)+5 : cod_get_user_maks_health(client));
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_klase[client])
		return Plugin_Continue;

	pulapkiGracza[client] = 2;
	return Plugin_Continue;
}