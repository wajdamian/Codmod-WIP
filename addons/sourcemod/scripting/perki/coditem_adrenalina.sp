#include <sourcemod>
#include <codmod>

new const String:nazwa[] = "Adrenalina";
new const String:opis[] = "Co 5 sekund regeneruje LW HP";

new bool:ma_item[65],
	wartosc_itemu[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 5, 9);
}
public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
	wartosc_itemu[client] = wartosc;
	CreateTimer(5.0, Regeneracja, client, TIMER_FLAG_NO_MAPCHANGE);
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public Action:Regeneracja(Handle:timer, any:client)
{
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	if(IsPlayerAlive(client))
	{
		new zdrowie_gracza = GetClientHealth(client);
		new maksymalne_zdrowie = cod_get_user_maks_health(client);
		SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (zdrowie_gracza+wartosc_itemu[client] < maksymalne_zdrowie)? zdrowie_gracza+wartosc_itemu[client]: maksymalne_zdrowie);
	}

	CreateTimer(3.0, Regeneracja, client, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}