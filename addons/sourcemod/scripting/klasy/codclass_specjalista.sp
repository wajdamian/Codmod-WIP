#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Specjalista [P]";
new const String:opis[] = "Stawia 3 miny laserowe, laser zadaje 200dmg, +5hp regen co 6 sec, 0.3regen/int, magazynek po killu, moze kupic kazdy granat.";
new const String:bronie[] = "#weapon_m4a1_silencer#weapon_usp_silencer";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 0;
new const wytrzymalosc = 15;
new const kondycja = 15;
new const flagi = ADMFLAG_CUSTOM4;

new bool:ma_klase[65];

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
	description = "Szpec od min laserowych i zarywania nocek przy pisaniu tej jebanej klasy. PLUJE NA NIĄ TFU JEBAĆ",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	CreateTimer(0.1, ZarejestrujDevklase);
}

public cod_class_enabled(client)
{
	ma_klase[client] = true;
	CreateTimer(6.0, Leczenie, client, TIMER_REPEAT);
} 
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}
public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
}
public cod_class_skill_used(client)
{
	if (ma_klase[client] && IsPlayerAlive(client))
	{
		FakeClientCommandEx(client, "sm_laser");
	}
}

public Action:Leczenie(Handle:Timer, any:client)
{
	if (!ma_klase[client] || !IsPlayerAlive(client) || !IsClientInGame(client) || !IsValidClient(client))
	{
		return Plugin_Stop;
	}
	new wartosc = 5 + RoundFloat(Float:cod_get_user_maks_intelligence(client)*0.3);
	SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (GetClientHealth(client)+wartosc < cod_get_user_maks_health(client))? GetClientHealth(client)+wartosc : cod_get_user_maks_health(client));
	return Plugin_Continue;
}

public Action:SmiercGracza(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(killer) || !ma_klase[killer])
		return Plugin_Continue;

	if(!IsValidClient(client) || !IsPlayerAlive(killer))
		return Plugin_Continue;

	if(GetClientTeam(client) == GetClientTeam(killer))
		return Plugin_Continue;

	new active_weapon = GetEntPropEnt(killer, Prop_Send, "m_hActiveWeapon");
	if(active_weapon != -1)
	{
		new String:weapon[32];
		GetClientWeapon(killer, weapon, sizeof(weapon));
		for(new i = 0; i < sizeof(nazwy_broni); i ++)
		{
			if(StrEqual(weapon, nazwy_broni[i]))
			{
				SetEntData(active_weapon, FindSendPropInfo("CWeaponCSBase", "m_iClip1"), naboje_broni[i][0]);
				break;
			}
		}
	}
	return Plugin_Continue;
}