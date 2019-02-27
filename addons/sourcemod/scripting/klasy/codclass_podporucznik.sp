#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Podporucznik";
new const String:opis[] = "Zamiana miejsc z przeciwnikiem, 1 + int/25 podmianek, int zwieksza zasieg, 10hp/kill, +10dmg beretty, +5dmg galil.";
new const String:bronie[] = "#weapon_galilar#weapon_elite#weapon_molotov";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];
	podmianki[65];
new Float:zasiegSkilla[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Podporucznik",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	HookEvent("player_spawn", OdrodzenieGracza);
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
	podmianki[client] = 1+cod_get_user_maks_intelligence(client)/25;
	zasiegSkilla[client] = 1000.0+cod_get_user_maks_intelligence(client)*10;
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
	if(damagetype & (DMG_BULLET) && GetClientButtons(attacker) & IN_ATTACK && StrEqual(weapon, "weapon_galilar", false))
	{
		damage+=5;
		return Plugin_Changed;
	}
	if(damagetype & (DMG_BULLET) && GetClientButtons(attacker) & IN_ATTACK && StrEqual(weapon,"weapon_elite", false))
	{
		damage+=10;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OnPlayerDeath(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(!IsValidClient(killer) || !ma_klase[killer])
		return Plugin_Continue;

	if(!IsValidClient(client) || !IsPlayerAlive(killer))
		return Plugin_Continue;

	if(GetClientTeam(client) == GetClientTeam(killer))
		return Plugin_Continue;
	
	new zdrowie_gracza = GetClientHealth(killer);
	new maksymalne_zdrowie = cod_get_user_maks_health(killer);
	SetEntData(killer, FindDataMapInfo(killer, "m_iHealth"), (zdrowie_gracza+10 < maksymalne_zdrowie)? zdrowie_gracza+10: maksymalne_zdrowie);

	return Plugin_Continue;
}


public cod_class_skill_used(client)
{	
	if (podmianki[client] == 0)
	{
		PrintToChat(client, "Wykorzystales juz wszystkie swoje podmianki!");
	}
	else
	{
		new Float:tpOrigin[3], Float:playerOrigin[3];
		new String:nazwaUzywajacego[32];
		GetClientName(client, nazwaUzywajacego, sizeof(nazwaUzywajacego));
		GetClientAbsOrigin(client, playerOrigin);
		
		for(new i = 1; i <= MAXPLAYERS+1; i++)
		{
			if(!IsClientInGame(i) || !IsPlayerAlive(i))
				continue;

			if(GetClientTeam(client) == GetClientTeam(i))
				continue;
		
			if(cod_get_user_item(i) == cod_get_itemid("Tarcza SWAT"))
				continue;

			GetClientEyePosition(i, tpOrigin);
			if(GetVectorDistance(playerOrigin, tpOrigin) <= zasiegSkilla[client])
			{
				tpOrigin[2] -=25;
				TeleportEntity(client, tpOrigin, NULL_VECTOR, NULL_VECTOR);
				TeleportEntity(i, playerOrigin, NULL_VECTOR, NULL_VECTOR);
				podmianki[client]--;
				new String: nazwaPodmienionego[32];
				GetClientName(i, nazwaPodmienionego, sizeof(nazwaPodmienionego));
				PrintToChat(client, "Podmieniles sie z %s!",nazwaPodmienionego);
				break;
			}
		}
	}
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_klase[client])
		return Plugin_Continue;

	podmianki[client] = 1+cod_get_user_maks_intelligence(client)/25;
	return Plugin_Continue;
}