#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Major [P]";
new const String:opis[] = "1/6 Instakill i 1/3 na podpalenie (3sekundy za 30hp/sec) z MAG-7; 1/15 na odbicie obrazen spowrotem do przeciwnika.";
new const String:bronie[] = "#weapon_mag7#weapon_p250";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 10;
new const wytrzymalosc = 10;
new const kondycja = 10;
new const flagi = (ADMFLAG_CHAT|ADMFLAG_CUSTOM1);

new bool:ma_klase[65];
new bool:czyOtruty[65];
new g_iTimerCount[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Major [P]",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	CreateTimer(0.1, ZarejestrujDevklase);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public cod_class_enabled(client)
{
	ma_klase[client] = true;
} 
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
		
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_mag7", false))
	{
		if(GetRandomInt(1, 6) == 1)
		{
			if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
				return Plugin_Continue;
			damage = 999.0;
			PrintToChat(attacker, "Instakill!");
			return Plugin_Changed;
		}
		else
		{
			if(GetRandomInt(1,3)==1 && !czyOtruty[client] && IsPlayerAlive(client))
			{
				if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
					return Plugin_Continue;
				czyOtruty[client] = true;
				PrintToChat(attacker, "Otrules przeciwnika!");
				DataPack hData;
				CreateDataTimer(1.0, Podpalenie, hData, TIMER_REPEAT);
				WritePackCell(hData, GetClientSerial(client));
				WritePackCell(hData, GetClientSerial(attacker));
				g_iTimerCount[client] = 1;
			}
		}
	}
	return Plugin_Continue;
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(client) || !IsValidClient(attacker))
		return Plugin_Continue;
	
	if (GetClientTeam(client) == GetClientTeam(attacker) || !ma_klase[client])
		return Plugin_Continue;
	
	if (GetRandomInt(1, 15) == 1)
	{
		PrintToChat(client, "Odbiles obrazenia!");
		cod_inflict_damage(attacker,client,RoundFloat(damage));
		damage = 0.0;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:Podpalenie(Handle:Timer, Handle:hData)
{
	ResetPack(hData);
	new victim = GetClientFromSerial(ReadPackCell(hData));
	new attacker = GetClientFromSerial(ReadPackCell(hData));
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
	cod_inflict_damage(victim, attacker, 30); 
	return Plugin_Continue;
}
