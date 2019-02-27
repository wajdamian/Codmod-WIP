#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Stabilne Statystyki";
new const String:opis[] = "Dostajesz +20 do wszystkich statystyk.";

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
public cod_item_enabled(client)
{
	ma_item[client] = true;
	cod_set_user_bonus_intelligence(client, 20);
	cod_set_user_bonus_health(client, 20);
	cod_set_user_bonus_damage(client, 20);
	cod_set_user_bonus_stamina(client, 20);
	cod_set_user_bonus_trim(client, 20);
}

public cod_item_disabled(client)
{
	ma_item[client] = false;
	cod_set_user_bonus_intelligence(client, 0);
	cod_set_user_bonus_health(client, 0);
	cod_set_user_bonus_damage(client, 0);
	cod_set_user_bonus_stamina(client, 0);
	cod_set_user_bonus_trim(client, 0);
}
