#include <sourcemod>
#include <codmod>

new const String:nazwa[] = "Akumulator 24V";
new const String:opis[] = "Posiadasz zwiększoną szybkostrzelność broni";

new bool:ma_item[65];
public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu",
	description = "Cod Perk",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu"
};
public OnPluginStart()
{
	cod_register_item(nazwa, opis, 0, 0);
}
public cod_item_enabled(client)
{
	ma_item[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapons)
{
	if(!IsValidClient(client) || !ma_item[client])
		return Plugin_Continue;

	if(!IsPlayerAlive(client))
		return Plugin_Continue;

	if(buttons & IN_ATTACK)
	{
		new active_weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(active_weapon != -1)
		{
			new Float:gametime = GetGameTime();
			new Float:fattack = GetEntDataFloat(active_weapon, FindSendPropInfo("CBaseCombatWeapon", "m_flNextPrimaryAttack"))-gametime;
			SetEntDataFloat(active_weapon, FindSendPropInfo("CBaseCombatWeapon", "m_flNextPrimaryAttack"), (fattack/1.4)+gametime);
		}
	}

	return Plugin_Continue;
}