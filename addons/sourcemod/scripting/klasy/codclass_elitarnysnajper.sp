#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Elitarny Snajper [P]";
new const String:opis[] = "1/2 na instakill z AWP, widocznosc zredukowana o 60%, AWP +3dmg/str, p250 +0.3dmg/str. Umiejetnosc: Zmienia pomiedzy awp/ssg08.";
new const String:bronie[] = "#weapon_awp#weapon_ssg08#weapon_p250";
new const inteligencja = 0;
new const zdrowie = 10;
new const obrazenia = 5;
new const wytrzymalosc = 10;
new const kondycja = 20;
new const flagi = ADMFLAG_CUSTOM2;

new bool:ma_klase[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Elitarny Snajper [P]",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	CreateTimer(0.1, ZarejestrujDevklase);
	HookEvent("player_spawn", OdrodzenieGracza);
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
	SetEntityRenderMode(client, RENDER_TRANSALPHA);
	SetEntityRenderColor(client, 100, 100, 100, 100);
} 
public cod_class_disabled(client)
{
	ma_klase[client] = false;
	SetEntityRenderMode(client, RENDER_TRANSALPHA);
	SetEntityRenderColor(client, 255, 255, 255, 255);
}

public cod_class_skill_used(client)
{
	if (ma_klase[client] && IsPlayerAlive(client))
	{
		new ent = GetPlayerWeaponSlot(client, 0);
		new String:weapon[32];
		GetClientWeapon(client, weapon, sizeof(weapon))
		if(StrEqual(weapon, "weapon_awp") && ent != -1)
		{
			AcceptEntityInput(ent, "Kill");
			GivePlayerItem(client, "weapon_ssg08");
		}
		if(StrEqual(weapon, "weapon_ssg08") && ent != -1)
		{
			AcceptEntityInput(ent, "Kill");
			GivePlayerItem(client, "weapon_awp");
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
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_awp", false))
	{
		if(GetRandomInt(1, 2) == 1)
		{
			if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
				return Plugin_Continue;
			damage = 999.0;
			PrintToChat(attacker, "Instakill!");
			return Plugin_Changed;
		}
		else
		{
			new String:szObrazenia[10];
			new Float:obrazenia_gracza;
			cod_get_user_maks_damage(attacker, szObrazenia, sizeof(szObrazenia));
			obrazenia_gracza = StringToFloat(szObrazenia);
			damage += obrazenia_gracza * 2;
			return Plugin_Changed;
		}
	}
	if(damagetype & (DMG_BULLET) && (GetClientButtons(attacker) & IN_ATTACK) && StrEqual(weapon, "weapon_p250", false))
	{
		new String:szObrazenia[10];
		new Float:obrazenia_gracza;
		cod_get_user_maks_damage(attacker, szObrazenia, sizeof(szObrazenia));
		obrazenia_gracza = StringToFloat(szObrazenia);
		damage+= obrazenia_gracza * 0.3;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!ma_klase[client] || !IsValidClient(client) || !IsClientInGame(client))
	return Plugin_Continue;
	
	SetEntityRenderMode(client, RENDER_TRANSALPHA);
	SetEntityRenderColor(client, 100, 100, 100, 100);
	return Plugin_Continue;
}