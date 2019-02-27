#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Klekotnik Jadowity [Dev]";
new const String:opis[] = "KLASA DLA DEVELOPERA. Cichy bieg, long jump, 1/3 na otrucie 5dmg + 1/4int na 3 sec, +0.5dmg/int. Poluje na kaczki.";
new const String:bronie[] = "#weapon_nova#weapon_fiveseven#weapon_molotov";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 20;
new const flagi = 0;

new bool:ma_klase[65];
new bool:skillReady[65];
new bool:czyOtruty[65];
new g_iTimerCount[65];
public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Klekotnik Jadowity [Dev]",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	CreateTimer(0.2, ZarejestrujDevklase);
	HookEvent("player_death", SmiercGracza);
}
public OnMapStart()
{
	AddFileToDownloadsTable("sound/cod/quack.wav");
	PrecacheSound("cod/quack.wav");
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
}

public cod_class_enabled(client)
{
	ma_klase[client] = true;
	skillReady[client] = true;
}
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public cod_class_skill_used(client)
{	
	if (skillReady[client] && ma_klase[client])
	{
		new Float:forigin[3];
		GetClientEyePosition(client, forigin);
		new Float:fangles[3];
		GetClientEyeAngles(client, fangles);
		new Float:iorigin[3], Float:iangles[3], Float:ivector[3];
		
		TR_TraceRayFilter(forigin, fangles, MASK_SOLID, RayType_Infinite, TraceRayFilter, client);
		TR_GetEndPosition(iorigin);
		MakeVectorFromPoints(forigin, iorigin, ivector);
		NormalizeVector(ivector, ivector);
		ScaleVector(ivector, 1000.0);
		GetVectorAngles(ivector, iangles);
		ivector[2]-=ivector[2];
		ivector[2]+=300;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, ivector);
		skillReady[client] = false;
		CreateTimer(10.0, SkillRenewal, client, TIMER_FLAG_NO_MAPCHANGE);
	} else 
		PrintToChat(client, "Nie możesz jeszcze użyć tej umiejętności!");
}
public bool:TraceRayFilter(ent, contents)
{
	return false;
}

public Action:SkillRenewal(Handle:Timer, any:client)
{
	if (!ma_klase[client])
		return Plugin_Continue;
	skillReady[client]=true;
	PrintToChat(client, "Możesz już użyć skoku!");
	return Plugin_Continue;
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
		
	if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
		return Plugin_Continue;
		
	damage += cod_get_user_maks_intelligence(attacker)/2;
	
	if(GetRandomInt(1,3)==1 && !czyOtruty[client] && IsPlayerAlive(client))
	{
		czyOtruty[client] = true;
		PrintToChat(attacker, "Otrules przeciwnika!");
		DataPack hData;
		CreateDataTimer(1.0, Podpalenie, hData, TIMER_REPEAT);
		WritePackCell(hData, GetClientSerial(client));
		WritePackCell(hData, GetClientSerial(attacker));
		g_iTimerCount[client] = 1;
	}
	return Plugin_Changed;
}

public Action:Podpalenie(Handle:Timer, Handle:hData)
{
	ResetPack(hData);
	new victim = GetClientFromSerial(ReadPackCell(hData));
	new attacker = GetClientFromSerial(ReadPackCell(hData));
	if (!IsValidClient(victim))
		return Plugin_Stop;
	if (!ma_klase[attacker])
	{
		g_iTimerCount[victim] = 1;
		czyOtruty[victim] = false;
		return Plugin_Stop;
	}
	if (Timer == INVALID_HANDLE)
	{
		czyOtruty[victim] = false;
	}
	else if (!IsPlayerAlive(victim) || !IsClientInGame(victim) || !IsClientInGame(attacker) || !czyOtruty[victim] || g_iTimerCount[victim] >= 3)
	{
		g_iTimerCount[victim] = 1;
		czyOtruty[victim] = false;
		return Plugin_Stop;
	}

	g_iTimerCount[victim]++;
	cod_inflict_damage(victim, attacker, 10+RoundToFloor(cod_get_user_maks_intelligence(attacker)*0.25)); 
	return Plugin_Continue;
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if (!ma_klase[attacker] || !IsValidClient(attacker))
		return Plugin_Continue;
		
	new Float:dOrigin[3];
	GetClientEyePosition(client, dOrigin);
	EmitAmbientSound("cod/quack.wav", dOrigin, _, SNDLEVEL_GUNFIRE, _, 1.0);
	return Plugin_Continue;
}

public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
}