#include <sourcemod>
#include <sdktools>
#include <codmod>
#include <sdkhooks>

new const String:nazwa[] = "Eliminator Rozrzutu";
new const String:opis[] = "Posiadasz No-Recoil";

new bool:ma_item[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "cod perk",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
	EnableNoRecoil(client);
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
	DisableNoRecoil(client);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!ma_item[client] || !IsValidClient(client))
		return Plugin_Continue;
	if (GetClientButtons(client) & IN_ATTACK)
	{
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngle", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_aimPunchAngleVel", NULL_VECTOR);
		SetEntPropVector(client, Prop_Send, "m_viewPunchAngle", NULL_VECTOR);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public EnableNoRecoil(client)
{
	SendConVarValue(client, FindConVar("weapon_accuracy_nospread"), "1");
	SendConVarValue(client, FindConVar("weapon_recoil_cooldown"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_cooldown"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_decay1_exp"), "99999");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_exp"), "99999");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_lin"), "99999");
	SendConVarValue(client, FindConVar("weapon_recoil_scale"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_suppression_shots"), "500");
}
public DisableNoRecoil(client)
{
	SendConVarValue(client, FindConVar("weapon_accuracy_nospread"), "0");
	SendConVarValue(client, FindConVar("weapon_recoil_cooldown"), "0.55");
	SendConVarValue(client, FindConVar("weapon_recoil_decay1_exp"), "3.5");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_exp"), "8");
	SendConVarValue(client, FindConVar("weapon_recoil_decay2_lin"), "18");
	SendConVarValue(client, FindConVar("weapon_recoil_scale"), "2");
	SendConVarValue(client, FindConVar("weapon_recoil_suppression_shots"), "4");
}