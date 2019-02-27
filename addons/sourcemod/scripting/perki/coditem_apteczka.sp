#include <sourcemod>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "Apteczka";
new const String:opis[] = "Użyj, aby przywrócić sobie pełne HP";

new bool:ma_item[65],
	bool:uzyty_item[65];

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
	cod_register_item(nazwa, opis, 0, 0);
	HookEvent("player_spawn", OdrodzenieGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	uzyty_item[client] = false;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public cod_item_used(client)
{
	if(uzyty_item[client])
		PrintToChat(client, "[COD] Wykorzystales już moc perku w tym życiu!");
	else
	{
		new maksymalne_zdrowie = cod_get_user_maks_health(client);
		SetEntData(client, FindDataMapInfo(client, "m_iHealth"), maksymalne_zdrowie);
		uzyty_item[client] = true;
	}
}
public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	uzyty_item[client] = false;
	return Plugin_Continue;
}