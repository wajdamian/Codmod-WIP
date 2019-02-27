#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Cytrynowy Alchemik [Dev]";
new const String:opis[] = "KLASA DLA DEVELOPERA. 1/3 na instakill z R8, zadaje +[0.5 * INT] obrażeń. Nie lubi, gdy ktoś mu ucieka.";
new const String:bronie[] = "#weapon_mp5sd#weapon_revolver#weapon_hegrenade#weapon_smokegrenade";
new const inteligencja = 0;
new const zdrowie = 20;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 20;
new const flagi = 0;

new bool:ma_klase[65];
new bool:skillReady[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Cytrynowy Alchemik [Dev]",
	version = "1.0",
	url = "https://steamcommunity.com/id/Zerciu"
};
public OnPluginStart()
{
	CreateTimer(0.2, ZarejestrujDevklase);
	HookEvent("player_death", SmiercGracza);
}
public OnMapStart()
{
	AddFileToDownloadsTable("sound/cod/runaway.wav");
	PrecacheSound("cod/runaway.wav");
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

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
		
	if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
		return Plugin_Continue;
		
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_revolver", false))
	{
		if(GetRandomInt(1, 3) == 1)
		{
			damage = 999.0;
			PrintToChat(attacker, "Instakill!");
			return Plugin_Changed;
		}	
	}
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_mp5sd", false))
	{
		damage += RoundToFloor(cod_get_user_maks_intelligence(attacker)*0.5);
		return Plugin_Changed;
	}	
	if(damagetype & (DMG_BLAST) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_hegrenade", false))
	{
		damage += RoundToFloor(GetClientHealth(attacker)*0.25);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new String:granat[32];
	if (!ma_klase[attacker] || !IsValidClient(attacker))
		return Plugin_Continue;
	GetEventString(event, "weapon", granat, sizeof(granat));
	if(StrEqual(granat, "hegrenade"))
		{
			new Float:dOrigin[3];
			GetClientEyePosition(client, dOrigin);
			EmitAmbientSound("cod/runaway.wav", dOrigin, _, SNDLEVEL_TRAIN, _, 1.0);
		}
	return Plugin_Continue;
}

public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
}