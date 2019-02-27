#include <sourcemod>
#include <codmod>

native set_user_esp(client, wartosc);
native get_user_esp(client);

new const String:nazwa[] = "Wallhack Czitera";
new const String:opis[] = "Widzisz pozycje przeciwnikow przez byty materialne";

public Plugin:myinfo =
{
	name = nazwa,
	author = "Linux`",
	description = "Cod Item",
	version = "1.0",
	url = "http://steamcommunity.com/id/linux2006"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
}
public cod_item_disabled(client)
{
	set_user_esp(client, 0);
}
public cod_item_used(client)
{
	set_user_esp(client, get_user_esp(client)? 0: 1);
}