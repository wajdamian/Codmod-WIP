#pragma semicolon 1

#define PLUGIN_AUTHOR "SM9 (xCoderx)"
#define PLUGIN_VERSION "0.1"

#pragma newdecls required
Handle hCvarPluginEnabled;

public Plugin myinfo = 
{
	name = "No Recoil", 
	author = PLUGIN_AUTHOR, 
	description = "No Recoil", 
	version = PLUGIN_VERSION, 
};

public void OnPluginStart()
{
	HookConVarChange(hCvarPluginEnabled = CreateConVar("sm_norecoil", "1", "Plugin enabled"), OnConVarChanged);
	UpdateConVars();
}

public void OnConVarChanged(Handle hConvar, const char[] chOldValue, const char[] chNewValue)
{
	UpdateConVars();
}

public void UpdateConVars()
{
	if (GetConVarBool(hCvarPluginEnabled))
	{
		SetConVarInt(FindConVar("weapon_accuracy_nospread"), 1);
		SetConVarInt(FindConVar("weapon_recoil_cooldown"), 0);
		SetConVarInt(FindConVar("weapon_recoil_cooldown"), 0);
		SetConVarInt(FindConVar("weapon_recoil_decay1_exp"), 99999);
		SetConVarInt(FindConVar("weapon_recoil_decay2_exp"), 99999);
		SetConVarInt(FindConVar("weapon_recoil_decay2_lin"), 99999);
		SetConVarInt(FindConVar("weapon_recoil_scale"), 0);
		SetConVarInt(FindConVar("weapon_recoil_suppression_shots"), 500);
	}
	
	else
	{
		SetConVarInt(FindConVar("weapon_accuracy_nospread"), 0);
		SetConVarFloat(FindConVar("weapon_recoil_cooldown"), 0.55);
		SetConVarFloat(FindConVar("weapon_recoil_decay1_exp"), 3.5);
		SetConVarInt(FindConVar("weapon_recoil_decay2_exp"), 8);
		SetConVarInt(FindConVar("weapon_recoil_decay2_lin"), 18);
		SetConVarInt(FindConVar("weapon_recoil_scale"), 2);
		SetConVarInt(FindConVar("weapon_recoil_suppression_shots"), 4);
	}
} 