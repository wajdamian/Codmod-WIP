#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Pas bojownika";
new const String:opis[] = "Otrzymujesz +25 ammo do pierwszego magazynka";

new bool:ma_item[65];
new String:nazwy_broni[][] =
{
	"weapon_glock", "weapon_usp_silencer", "weapon_hkp2000", "weapon_p250", "weapon_tec9", "weapon_fiveseven", "weapon_cz75a", "weapon_deagle",
	"weapon_revolver", "weapon_elite", "weapon_m4a1_silencer", "weapon_ak47", "weapon_awp", "weapon_m4a1", "weapon_negev", "weapon_famas",
	"weapon_aug", "weapon_p90", "weapon_nova", "weapon_xm1014", "weapon_mag7", "weapon_mac10", "weapon_mp7", "weapon_mp9", "weapon_bizon",
	"weapon_ump45", "weapon_galilar", "weapon_ssg08", "weapon_sg556", "weapon_m249", "weapon_scar20", "weapon_g3sg1", "weapon_sawedoff", "weapon_mp5sd"
};
new naboje_broni[][2] =
{
	{20, 120}, {12, 24}, {13, 52}, {13, 26}, {32, 120}, {20, 100}, {12, 12}, {7, 35}, {8, 8}, {30, 120}, {20, 40}, {30, 90}, {10, 30}, {30, 90}, {150, 200}, {25, 90}, {30, 90},
	{50, 100}, {8, 32}, {7, 32}, {5, 32}, {30, 100}, {30, 120}, {30, 120}, {64, 120}, {25, 100}, {35, 90}, {10, 90}, {30, 90}, {100, 200}, {20, 90}, {20, 90}, {7, 32}, {30,120}
};

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
	CreateTimer(0.1, HookBroni, client, TIMER_FLAG_NO_MAPCHANGE);
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client=GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsClientInGame(client) || !ma_item[client])
		return Plugin_Continue;

	CreateTimer(0.1, HookBroni, client, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action:HookBroni(Handle:Timer, any:client)
{
    for(new i=0; i<2; i++) 
    {
        new weapon=GetPlayerWeaponSlot(client, i);
        if(IsValidEntity(weapon))
        {
			new String:szWeapon[64];
			GetEdictClassname(weapon, szWeapon, sizeof(szWeapon));
			for (new j=0; j < sizeof(nazwy_broni); j++)
			{
				if (StrEqual(szWeapon, nazwy_broni[j],false))
				{
					SetEntData(weapon, FindSendPropInfo("CWeaponCSBase", "m_iClip1"), naboje_broni[j][0]+25);
				}
			}
        }
    }
}