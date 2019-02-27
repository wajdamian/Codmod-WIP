#include <sourcemod>
#include <codmod>

new const String:nazwa[] = "Wytrenowany Weteran";
new const String:opis[] = "Dostajesz +50HP oraz 100 Wytrzymałości, lecz tracisz 20 Kondycji";

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
	cod_set_user_bonus_health(client, cod_get_user_health(client, 0, 1, 0)+25);
	cod_set_user_bonus_stamina(client, cod_get_user_stamina(client, 0, 1, 0)+50);
	cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)-20);
}
public cod_item_disabled(client)
{
	cod_set_user_bonus_health(client, cod_get_user_health(client, 0, 1, 0)-25);
	cod_set_user_bonus_stamina(client, cod_get_user_stamina(client, 0, 1, 0)-50);
	cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)+20);
}