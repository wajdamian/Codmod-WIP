#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Plecak Najemnika";
new const String:opis[] = "5000$ oraz losowa broń co rundę";

new String:nazwy_broni[][] =
{
	"weapon_glock", "weapon_usp_silencer", "weapon_hkp2000", "weapon_p250", "weapon_tec9", "weapon_fiveseven", "weapon_cz75a", "weapon_deagle",
	"weapon_revolver", "weapon_elite", "weapon_m4a1_silencer", "weapon_ak47", "weapon_awp", "weapon_m4a1", "weapon_negev", "weapon_famas",
	"weapon_aug", "weapon_p90", "weapon_nova", "weapon_xm1014", "weapon_mag7", "weapon_mac10", "weapon_mp7", "weapon_mp9", "weapon_bizon",
	"weapon_ump45", "weapon_galilar", "weapon_ssg08", "weapon_sg556", "weapon_m249", "weapon_scar20", "weapon_g3sg1", "weapon_sawedoff", "weapon_mp5sd"
};

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
	HookEvent("player_spawn", OdrodzenieGracza, EventHookMode_Pre);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (ma_item[client])
	{
		new random = GetRandomInt(0, sizeof(nazwy_broni));
		new String:weapons[256];
		Format(weapons, sizeof(weapons), "%s", nazwy_broni[random]);
		cod_set_user_bonus_weapons(client, weapons);
		new clientCash = GetEntProp(client, Prop_Send, "m_iAccount");
		SetEntProp(client, Prop_Send, "m_iAccount", ((clientCash + 5000 < 16000)? clientCash+5000 : 16000));
	}
}