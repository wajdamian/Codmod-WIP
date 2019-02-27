#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Komandos [P]";
new const String:opis[] = "Natychmiastowo zabija z noza na ppm, malo widoczny gdy kuca";
new const String:bronie[] = "#weapon_deagle";
new const inteligencja = 0;
new const zdrowie = 20;
new const obrazenia = 0;
new const wytrzymalosc = 0;
new const kondycja = 25;
new const flagi = ADMFLAG_CUSTOM1;

new bool:skillReady[65];
new bool:ma_klase[65];
bonus_kondycha[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Komandos",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	CreateTimer(0.1, ZarejestrujDevklase);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}
public Action:ZarejestrujDevklase(Handle:Timer, any:data)
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	return;
}
public cod_class_enabled(client)
{
	ma_klase[client] = true;
	skillReady[client] = true;
	bonus_kondycha[client] = 50;
}
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}
public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(attacker) || !ma_klase[attacker])
		return Plugin_Continue;

	if(!IsValidClient(client) || GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	new String:weapon[32];
	GetClientWeapon(attacker, weapon, sizeof(weapon));
	if((StrEqual(weapon, "weapon_bayonet") || StrContains(weapon, "weapon_knife", false) != -1) && damagetype & (DMG_SLASH|DMG_BULLET) && GetClientButtons(attacker) & IN_ATTACK2)
	{
		if(cod_get_user_item(client) == cod_get_itemid("Tarcza SWAT"))
			return Plugin_Continue;
		damage = 999.0;
		PrintToChat(attacker, "Instakill!");
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if ( ma_klase[client] && (GetClientButtons(client) & IN_DUCK))
	{
		SetEntityRenderMode(client, RENDER_TRANSALPHA); 
		SetEntityRenderColor(client, _, _, _, 25); 
	}
	else if (ma_klase[client])
	{
		SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255,255,255,255);
	}
	return Plugin_Continue;
}

public cod_class_skill_used(client)
{
	if (ma_klase[client] && skillReady[client])
	{
		cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)+bonus_kondycha[client]);
		skillReady[client] = false;
		CreateTimer(2.0, EndSkill, client, TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(17.0, RefreshSkillUsage, client, TIMER_FLAG_NO_MAPCHANGE);
		PrintToChat(client,"Dostales +50 kondycji na 2 sek!");
	}
	else
	{
		PrintToChat(client,"Nie możesz jeszcze użyć tej umiejętności!");
	}
}

public Action:EndSkill(Handle:timer, any:client)
{
	cod_set_user_bonus_trim(client, cod_get_user_trim(client, 0, 1, 0)-bonus_kondycha[client]);
}

public Action:RefreshSkillUsage(Handle:timer, any:client)
{
	skillReady[client] = true;
	PrintToChat(client, "Mozesz znowu uzyc umiejetnosci!");
}