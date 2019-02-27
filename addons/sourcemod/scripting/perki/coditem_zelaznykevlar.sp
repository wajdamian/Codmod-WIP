#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Zelazny Kevlar";
new const String:opis[] = "+40 wytrzymalosci";

new bool:ma_item[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	cod_set_user_bonus_stamina(client, cod_get_user_stamina(client, 0, 1, 0)+40) ;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
	cod_set_user_bonus_stamina(client, cod_get_user_stamina(client, 0, 1, 0)-40) ;
}
