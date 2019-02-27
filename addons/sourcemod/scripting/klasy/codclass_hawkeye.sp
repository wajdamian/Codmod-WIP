#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Hawkeye";
new const String:opis[] = "Posiada granat taktyczny i moduł odrzutowy, w czasie lotu jest niewidzialny, zwiekszone DMG o 5";
new const String:bronie[] = "#weapon_famas#weapon_p250#weapon_tagrenade";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];
new bool:skillReady[65];
new bool:jestNiewidzialny[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Hawkeye",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
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
		SetEntityRenderMode(client, RENDER_TRANSALPHA); 
		SetEntityRenderColor(client, _, _, _, 25); 
		CreateTimer(0.1, GoInvisible, client, TIMER_FLAG_NO_MAPCHANGE);
		skillReady[client] = false;
		CreateTimer(10.0, SkillRenewal, client, TIMER_FLAG_NO_MAPCHANGE);
	} else PrintToChat(client, "Nie możesz jeszcze użyć tej umiejętności!");
}
public bool:TraceRayFilter(ent, contents)
{
	return false;
}
public Action:GoInvisible(Handle:Timer, any:client)
{
	jestNiewidzialny[client] = true;
}

public Action:SkillRenewal(Handle:Timer, any:client)
{
	skillReady[client]=true;
	PrintToChat(client, "Możesz już użyć skoku!");
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if ( ma_klase[client] && IsValidClient(client))
	{ 
		if ((GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == 0) && jestNiewidzialny[client])
		{
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			SetEntityRenderColor(client, 255,255,255,255);
			jestNiewidzialny[client] = false;
		}
	}
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
		
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(damagetype & (DMG_BULLET) && GetClientButtons(attacker) & IN_ATTACK)
	{
		damage+=5;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
