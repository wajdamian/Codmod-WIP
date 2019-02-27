#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <codmod>

new const String:nazwa[] = "Luneta";
new const String:opis[] = "Posiadasz przybliżenie do każdej bronii";

new bool:ma_item[65];
new g_iFOV[MAXPLAYERS + 1] = { -1 }

public Plugin:myinfo =
{
	name = nazwa,
	author = ".nbd",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/geneccc"
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

public void OnClientPutInServer(int client)
{
    g_iFOV[client] = -1;
}

public cod_item_used(client)
{
	if(IsPlayerAlive(client)){
		int iFOV = GetEntProp(client, Prop_Send, "m_iFOV");
		if(iFOV == 15){
			SetEntProp(client, Prop_Send, "m_iFOV", g_iFOV[client]);
		} else {
			g_iFOV[client] = iFOV;
			SetEntProp(client, Prop_Send, "m_iFOV", 15);
        }
    }
}