#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

#include <codmod>


#define CHAT_PREFIX "  \x06[\x0BSklep\x06] "
#define CHAT_PREFIX_RULETKA "  \x06[\x0BRuletka\x06] "

#pragma semicolon 1

#define USAGE_ALIVE 1
#define USAGE_DEATH 2
#define USAGE_BOTH 3

enum eItemDefinition {
	String:Item_Name[100],
	Item_Price,
	Function:Item_Function,
	Item_Usage,
	Item_Params1,
	Item_Params2,
}

int g_iItems[][eItemDefinition] = {
	{"Regeneracja HP", 5000, INVALID_FUNCTION, USAGE_ALIVE,0,0},
	{"Losowy perk", 10000, INVALID_FUNCTION, USAGE_BOTH,0,0},
	{"Mały EXP", 3000, INVALID_FUNCTION, USAGE_BOTH, 1, 500},
	{"Średni EXP", 8000, INVALID_FUNCTION, USAGE_BOTH,500,750},
	{"Duży EXP", 16000, INVALID_FUNCTION, USAGE_BOTH,750,1200}, //Pamiętać że musi być na 4 albo zmienić indeks w obsłudze menu sklepu
	{"Ruletka", 6000, INVALID_FUNCTION, USAGE_ALIVE,0,0},
};

public Plugin myinfo =  {
	name = "Codmod - shop",
	author = ".nbd",
	description = "System sklepu",
	version = "0.1",
	url = "https://steamcommunity.com/id/geneccc/"
};

public OnPluginStart() {
	RegConsoleCmd("sm_sklep", Command_Shop);

	g_iItems[0][Item_Function] = Shop_HpRegen;
	g_iItems[1][Item_Function] = Shop_RandomPerk;
	g_iItems[2][Item_Function] = Shop_Exp;
	g_iItems[3][Item_Function] = Shop_Exp;
	g_iItems[4][Item_Function] = Shop_Exp;
	g_iItems[5][Item_Function] = Shop_Ruletka;
}

public Action Command_Shop(int iClient, int iArgs) {
	Menu hMenu = new Menu(Menu_Nsm);
	hMenu.SetTitle("Sklep CodMod");
	char tmp[128];
	bool bDraw;
	for(int i = 0; i < sizeof(g_iItems); i++) {
		bDraw = true;
		if( (g_iItems[i][Item_Usage] == USAGE_ALIVE && !IsPlayerAlive(iClient)) || (g_iItems[i][Item_Usage] == USAGE_DEATH && IsPlayerAlive(iClient))) {
			bDraw = false;
		}
		Format(tmp, sizeof(tmp), "%s [%d$]", g_iItems[i][Item_Name], g_iItems[i][Item_Price]);
		hMenu.AddItem(g_iItems[i][Item_Name], tmp, bDraw ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED );
	}

	hMenu.Display(iClient, 30);
}

public int Menu_Nsm(Menu menu, MenuAction action, int iClient, int iOption) {
	if(action == MenuAction_Select) {
		switch(g_iItems[iOption][Item_Usage]) {
			case USAGE_ALIVE: {
				if(!(IsPlayerAlive(iClient))) {
					PrintToChat(iClient, "%s \x0fMusisz byc zywy aby kupic %s!", CHAT_PREFIX, g_iItems[iOption][Item_Name]);
					return 0;
				}
			}
			case USAGE_DEATH: {
				if(IsPlayerAlive(iClient)) {
					PrintToChat(iClient, "%s \x0fMusisz byc martwy aby kupic %s!", CHAT_PREFIX, g_iItems[iOption][Item_Name]);
					return 0;
				}
			}
		}
		if(GetEntProp(iClient, Prop_Send, "m_iAccount") < g_iItems[iOption][Item_Price]) {
			PrintToChat(iClient, "%s Brakuje Ci %d$ na zakup %s!", CHAT_PREFIX, g_iItems[iOption][Item_Price] - GetEntProp(iClient, Prop_Send, "m_iAccount"), g_iItems[iOption][Item_Name]);
			return 0;
		}
		any result;
		if(g_iItems[iOption][Item_Function] != INVALID_FUNCTION) {
			Call_StartFunction(INVALID_HANDLE, g_iItems[iOption][Item_Function]);
			Call_PushCell(iClient);
			Call_PushCell(iOption);
			Call_Finish(result);
		}

		SetEntProp(iClient, Prop_Send, "m_iAccount", GetEntProp(iClient, Prop_Send, "m_iAccount") -  g_iItems[iOption][Item_Price]);
		if(result > 0 && result <= g_iItems[4][Item_Params2])
			PrintToChat(iClient, "%s Zakupiles %s(%i EXP)!", CHAT_PREFIX, g_iItems[iOption][Item_Name], result);
		else
			PrintToChat(iClient, "%s Zakupiles %s!", CHAT_PREFIX, g_iItems[iOption][Item_Name]);
	}

	return 1;
}

public int Shop_Exp(int iClient, int iOption) {
	int iExp = GetRandomInt(g_iItems[iOption][Item_Params1], g_iItems[iOption][Item_Params2]);
	cod_add_user_xp(iClient, iExp);
	return iExp;
}

public void Shop_HpRegen(int iClient, int iOption) {
	SetEntData(iClient, FindDataMapInfo(iClient, "m_iHealth"), GetEntData(iClient, FindDataMapInfo(iClient, "m_iMaxHealth")));
}

public void Shop_RandomPerk(int iClient, int iOption) {
	cod_set_user_item(iClient, -1, -1, -1);
}

public void Shop_Ruletka(int iClient, int iOption) {
	int chance = GetRandomInt(1,100);
	if(chance < 66) {
		ForcePlayerSuicide(iClient);
		PrintToChat(iClient, "%s Umarłeś przez ruletkę", CHAT_PREFIX_RULETKA);
	}
	else if (chance < 80) {
		PrintToChat(iClient, "%s Nic się nie stało", CHAT_PREFIX_RULETKA);
	}
	else if (chance < 90) {
		cod_set_user_item(iClient, -1, -1, -1);
		PrintToChat(iClient, "%s Ruletka dała Ci losowy przedmiot", CHAT_PREFIX_RULETKA);
	}
	else if (chance < 95) {
		int iExp = GetRandomInt(100, 250);
		PrintToChat(iClient, "%s Dostałeś marne %i EXP", CHAT_PREFIX_RULETKA, iExp);
		cod_add_user_xp(iClient, iExp);
	}
	else {
		int iExp = GetRandomInt(500, 750);
		PrintToChat(iClient, "%s Ruletka obdarzyła Cię %i EXP", CHAT_PREFIX_RULETKA, iExp);
		cod_add_user_xp(iClient, iExp);
	}
}