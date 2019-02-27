#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Strzelec Wyborowy [P]";
new const String:opis[] = "+5dmg, 1/6 na zredukowanie pocisku, 1/6 na zamrożenie na 2sek.";
new const String:bronie[] = "#weapon_m4a1_silencer#weapon_ak47#weapon_usp_silencer";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 10;
new const wytrzymalosc = 15;
new const kondycja = 10;
new const flagi = ADMFLAG_CUSTOM6;

new bool:ma_klase[65];
new bool:skillReady[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Strzelec Wyborowy [P]",
	version = "1.0",
	url = "https://steamcommunity.com/id/Zerciu"
};

public OnPluginStart()
{
	CreateTimer(0.1, ZarejestrujDevklase);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
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
	if (skillReady[client] && ma_klase[client] && IsPlayerAlive(client))
	{
		new ent = GetPlayerWeaponSlot(client, 0);
		new String:weapon[32];
		GetClientWeapon(client, weapon, sizeof(weapon))
		if(StrEqual(weapon, "weapon_ak47") && ent != -1)
		{
			AcceptEntityInput(ent, "Kill");
			GivePlayerItem(client, "weapon_m4a1_silencer");

		}
		if(StrEqual(weapon, "weapon_m4a1_silencer") && ent != -1)
		{
			AcceptEntityInput(ent, "Kill");
			GivePlayerItem(client, "weapon_ak47");

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
		if(GetRandomInt(1, 6) == 1)
		{
			new mrozonka = GetClientUserId(client);
			SetEntityMoveType(client, MOVETYPE_NONE);
			PrintToChat(attacker,"Zamroziles przeciwnika!");
			CreateTimer(2.0, Zamrozenie, mrozonka, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(client) || !IsValidClient(attacker) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
	
	if (ma_klase[client] && IsPlayerAlive(client))
	{
		if ((damagetype & (DMG_BLAST)) && GetRandomInt(1,6)==3)
		{
			damage = 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public Action:Zamrozenie(Handle:timer, mrozonka)
{
	new client = GetClientOfUserId(mrozonka);
	if (!IsClientInGame(client) || !IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;
		
	SetEntityMoveType(client, MOVETYPE_WALK);
	return Plugin_Continue;
}