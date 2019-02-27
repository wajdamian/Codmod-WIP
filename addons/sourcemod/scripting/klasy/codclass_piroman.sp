#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>
 
new const String:nazwa[] = "Piroman";
new const String:opis[] = "Posiada 1/12 na podpalenie, zadające [10 + 0.2 * INT] obrażeń";
new const String:bronie[] = "#weapon_bizon#weapon_elite";
new const inteligencja = 0;
new const zdrowie = 12;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;
 
new bool:ma_klase[65];
new bool:czyPodpalony[65];
new g_iTimerCount[65];

public Plugin:myinfo =
{
    name = nazwa,
    author = "Zerciu & de duk goos quak m8",
    description = "Piroman",
    version = "1.0",
    url = "http://steamcommunity.com/id/Zerciu https://steamcommunity.com/profiles/76561198145991535/"
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
		
	damage += 5;
	if(GetRandomInt(1,12)==1 && !czyPodpalony[client] && IsPlayerAlive(client))
	{
		if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
			return Plugin_Continue;
			
		czyPodpalony[client] = true;
		PrintToChat(attacker, "Podpaliłeś przeciwnika!");
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
	if (Timer == INVALID_HANDLE)
	{
		czyPodpalony[victim] = false;
	}
	else if (!IsPlayerAlive(victim) || !IsClientInGame(victim) || !IsClientInGame(attacker) || !czyPodpalony[victim] || g_iTimerCount[victim] >= 3)
	{
		g_iTimerCount[victim] = 1;
		czyPodpalony[victim] = false;
		return Plugin_Stop;
	}

	g_iTimerCount[victim]++;
	cod_inflict_damage(victim, attacker, 10+RoundToFloor(cod_get_user_maks_intelligence(attacker)*0.2)); 
	return Plugin_Continue;
}