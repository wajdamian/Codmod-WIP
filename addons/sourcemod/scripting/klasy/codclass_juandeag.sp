#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Juan Deag";
new const String:opis[] = "Instakill w glowe z deagle, refill ammo po killu, 1 obrazen = 0.5dmg";
new const String:bronie[] = "#weapon_deagle";
new const inteligencja = 0;
new const zdrowie = 5;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];

new String:nazwy_broni[][] =
{
	"weapon_glock", "weapon_usp_silencer", "weapon_hkp2000", "weapon_p250", "weapon_tec9", "weapon_fiveseven", "weapon_cz75a", "weapon_deagle",
	"weapon_revolver", "weapon_elite", "weapon_m4a1_silencer", "weapon_ak47", "weapon_awp", "weapon_m4a1", "weapon_negev", "weapon_famas",
	"weapon_aug", "weapon_p90", "weapon_nova", "weapon_xm1014", "weapon_mag7", "weapon_mac10", "weapon_mp7", "weapon_mp9", "weapon_bizon",
	"weapon_ump45", "weapon_galilar", "weapon_ssg08", "weapon_sg556", "weapon_m249", "weapon_scar20", "weapon_g3sg1", "weapon_sawedoff"
};
new naboje_broni[][2] =
{
	{20, 120}, {12, 24}, {13, 52}, {13, 26}, {32, 120}, {20, 100}, {12, 12}, {7, 35}, {8, 8}, {30, 120}, {20, 40}, {30, 90}, {10, 30}, {30, 90}, {150, 200}, {25, 90}, {30, 90},
	{50, 100}, {8, 32}, {7, 32}, {5, 32}, {30, 100}, {30, 120}, {30, 120}, {64, 120}, {25, 100}, {35, 90}, {10, 90}, {30, 90}, {100, 200}, {20, 90}, {20, 90}, {7, 32}
};

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Juan Deag",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	HookEvent("player_death", OnPlayerDeath);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_TraceAttack, OnHeadshot);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_TraceAttack, OnHeadshot);
}

public cod_class_enabled(client)
{
	ma_klase[client] = true;
}
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public Action:OnHeadshot(client, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
	
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && hitgroup == 1 && (StrEqual(weapon, "weapon_deagle")))
	{		
		if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
			return Plugin_Continue;
		damage = 999.0;
		PrintToChat(attacker, "Instakill!");
		return Plugin_Changed;
	}
	else if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK))
	{
		new String:szObrazenia[10];
		new Float:obrazenia_gracza;
		cod_get_user_maks_damage(attacker, szObrazenia, sizeof(szObrazenia));
		obrazenia_gracza = StringToFloat(szObrazenia);
		damage += obrazenia_gracza * 0.5;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(killer) || !ma_klase[killer])
		return;

	if(!IsValidClient(client) || !IsPlayerAlive(killer))
		return;

	if(GetClientTeam(client) == GetClientTeam(killer))
		return;

	new active_weapon = GetEntPropEnt(killer, Prop_Send, "m_hActiveWeapon");
	if(active_weapon != -1)
	{
		new String:weapon[32];
		GetClientWeapon(killer, weapon, sizeof(weapon));
		for(new i = 0; i < sizeof(nazwy_broni); i ++)
		{
			if(StrEqual(weapon, nazwy_broni[i]))
			{
				SetEntData(active_weapon, FindSendPropInfo("CWeaponCSBase", "m_iClip1"), naboje_broni[i][0]+1);
				break;
			}
		}
	}
}