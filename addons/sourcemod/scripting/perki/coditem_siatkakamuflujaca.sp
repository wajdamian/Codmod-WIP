#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Siatka kamuflujaca";
new const String:opis[] = "Twoja widocznosc jest zredukowana o 70%.";

new bool:ma_item[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
	HookEvent("player_spawn", OdrodzenieGracza);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	SetEntityRenderMode(client, RENDER_TRANSALPHA);
	SetEntityRenderColor(client, 255, 255, 255, 75);
}

public cod_item_disabled(client)
{
	ma_item[client] = false;
	SetEntityRenderColor(client, 255, 255, 255, 255);
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (ma_item[client])
	{
		SetEntityRenderMode(client, RENDER_TRANSALPHA);
		SetEntityRenderColor(client, 255, 255, 255, 75);
	}
}
