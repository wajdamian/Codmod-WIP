#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <codmod>

new const String:nazwa[] = "Zwrot do nadawcy";
new const String:opis[] = "Odbijasz dmg min";

new bool:ma_item[65];

public Plugin:myinfo =
{
	author = "de duk goos quak m8",
	description = "cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
}
public cod_item_enabled(client, wartosc)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
