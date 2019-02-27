#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Admiral";
new const String:opis[] = "Podwojny skok, +5dmg z famasa, uzupelnienie amunicji po zabiciu";
new const String:bronie[] = "#weapon_famas#weapon_p250";
new const inteligencja = 0;
new const zdrowie = 5;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65],
	g_FlagiPrzyciskiWczesniej[65],
	g_iSkoki[65];
	
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
	description = "Admiral",
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
	SDKHook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnDealDamage);
}
public cod_class_enabled(client)
{
	ma_klase[client] = true;
}
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public Action:OnDealDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;
		
	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if(StrEqual(weapon, "weapon_famas") && (damagetype & (DMG_BULLET)) && (GetClientButtons(attacker) & IN_ATTACK))
	{
		damage+=5;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(!IsValidClient(client) || !ma_klase[client] || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Continue;
		
	new flagiPrzyciskiTeraz = GetEntityFlags(client);
	if(flagiPrzyciskiTeraz & FL_ONGROUND)
	{
		g_iSkoki[client] = 0;
	}
	else if(!(g_FlagiPrzyciskiWczesniej[client] & IN_JUMP) && (buttons & IN_JUMP) && !(flagiPrzyciskiTeraz & FL_ONGROUND))
	{
		DrugiSkok(client);
	}
	g_FlagiPrzyciskiWczesniej[client] = buttons;
	return Plugin_Continue;
}

stock DrugiSkok(const any:client)
{
	if (g_iSkoki[client] < 1)
	{						
		g_iSkoki[client]++
		decl Float:vVelocity[3]
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVelocity)
		
		vVelocity[2] = 250.0
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVelocity)
	}
}

public OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(killer) || !ma_klase[killer])
		return ;

	if(!IsValidClient(client) || !IsPlayerAlive(killer))
		return ;

	if(GetClientTeam(client) == GetClientTeam(killer))
		return ;

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
