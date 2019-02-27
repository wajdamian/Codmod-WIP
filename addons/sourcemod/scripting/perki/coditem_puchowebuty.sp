#include <sourcemod>
#include <sdktools>
#include <codmod>

new const String:nazwa[] = "Puchowe Buty";
new const String:opis[] = "Nie słychać twoich kroków";


new bool:ma_item[65];
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
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}