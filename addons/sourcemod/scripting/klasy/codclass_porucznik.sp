#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Porucznik [P]";
new const String:opis[] = "AK 1/15 instakill, M4 leczenie 1/2 na 1/5 dmg. Po killu magazynek oraz +15HP. Zmiana broni pod bindem.";
new const String:bronie[] = "#weapon_ak47#weapon_m4a1#weapon_p250";
new const inteligencja = 0;
new const zdrowie = 5;
new const obrazenia = 5;
new const wytrzymalosc = 15;
new const kondycja = 10;
new const flagi = ADMFLAG_CUSTOM3;

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
	description = "Porucznik [P]",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	CreateTimer(0.1, ZarejestrujDevklase);
	HookEvent("player_death", SmiercGracza);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
}
public cod_class_enabled(client)
{
	ma_klase[client] = true;
} 
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public cod_class_skill_used(client)
{
	if (ma_klase[client] && IsPlayerAlive(client))
	{
		new ent = GetPlayerWeaponSlot(client, 0);
		new String:weapon[32];
		GetClientWeapon(client, weapon, sizeof(weapon))
		if(StrEqual(weapon, "weapon_ak47") && ent != -1)
		{
			AcceptEntityInput(ent, "Kill");
			GivePlayerItem(client, "weapon_m4a1");
		}
		if(StrEqual(weapon, "weapon_m4a1") && ent != -1)
		{
			AcceptEntityInput(ent, "Kill");
			GivePlayerItem(client, "weapon_ak47");
		}
	}
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
		
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_ak47", false))
	{
		if(GetRandomInt(1, 15) == 1)
		{
			if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
				return Plugin_Continue;
			damage = 999.0;
			PrintToChat(attacker, "Instakill!");
			return Plugin_Changed;
		}
	}
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_m4a1", false))
	{
		if(GetRandomInt(1, 2) == 1)
		{
			if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
				return Plugin_Continue;
			new zdrowie_gracza = GetClientHealth(attacker);
			new maksymalne_zdrowie = cod_get_user_maks_health(attacker);
			SetEntData(attacker, FindDataMapInfo(attacker, "m_iHealth"), (zdrowie_gracza+RoundToFloor(damage/5) < maksymalne_zdrowie)? zdrowie_gracza+RoundToFloor(damage/5): maksymalne_zdrowie);
			return Plugin_Continue;
		}
	}
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

	new zdrowie_gracza = GetClientHealth(killer);
	new maksymalne_zdrowie = cod_get_user_maks_health(killer);
	SetEntData(killer, FindDataMapInfo(killer, "m_iHealth"), (zdrowie_gracza+15 < maksymalne_zdrowie)? zdrowie_gracza+15: maksymalne_zdrowie);

	return Plugin_Continue;
}