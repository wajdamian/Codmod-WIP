#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>

#include <codmod>


#define CHAT_PREFIX "  \x06[\x0BNieśmiertelniki\x06] "

#pragma semicolon 1

public Plugin myinfo =  {
	name = "Nieśmiertelniki",
	author = ".nbd",
	description = "System sklepu",
	version = "0.1",
	url = "https://steamcommunity.com/id/geneccc/"
};

bool g_bLoaded[MAXPLAYERS + 1] =  { false };
float g_fAdditionalXpMult[MAXPLAYERS + 1] = { 0.0 };
StringMap g_smAdditionalXpOffline;
int g_iNsm[MAXPLAYERS + 1] = { 0 };
Database g_hDb = view_as<Database>(INVALID_HANDLE);

#define MINIMALNA_ILOSC_GRACZY 4

#define USAGE_ALIVE 1
#define USAGE_DEATH 2
#define USAGE_BOTH 3

enum eItemDefinition {
	String:Item_Name[100],
	Item_Price,
	Function:Item_Function,
	Item_Usage,
	Item_Params,
}

int g_iItems[][eItemDefinition] = {
	{"Regeneracja perku", 10, INVALID_FUNCTION, USAGE_BOTH,100},
	{"Zwiększenie XP o 25% na mapę", 100, INVALID_FUNCTION, USAGE_BOTH,25},
	{"HE 1/2 na kill", 20, INVALID_FUNCTION, USAGE_ALIVE,0},
	{"10 000 XP", 100, INVALID_FUNCTION, USAGE_BOTH,10000},
	{"5 000 XP", 50, INVALID_FUNCTION, USAGE_BOTH,5000},
};

public void OnPluginStart() {
	Database.Connect(GotDatabase,"cod_nsm");

	HookEvent("hostage_rescued", Event_ZakladnikUratowany);
	HookEvent("bomb_defused", Event_BombaRozbrojona);
	HookEvent("bomb_planted", Event_BombaPodlozona);

	g_iItems[0][Item_Function] = Shop_PerkRegen;
	g_iItems[1][Item_Function] = Shop_IncreasedXp;
	g_iItems[2][Item_Function] = Shop_SuperHE;
	g_iItems[3][Item_Function] = Shop_AddXp;
	g_iItems[4][Item_Function] = Shop_AddXp;

	RegConsoleCmd("sm_nsm", Command_Nsm);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max){
	g_smAdditionalXpOffline = new StringMap();
}

public void OnPluginEnd() {
	Db_SavePlayersData();
}

public void OnMapEnd() {
	Db_SavePlayersData();
	g_smAdditionalXpOffline.Clear();
	for(int i = 0; i < MAXPLAYERS; i++) {
		g_fAdditionalXpMult[i] = 0.0;
	}
}

public void GotDatabase(Database db, const char[] error, any data) {
	if(db == null)
		LogError("Database failure: %s", error);
	else
		g_hDb = db;

	//char query[255] = "CREATE TABLE IF NOT EXISTS `codmod_nsm` (`sid` varchar(64) DEFAULT NULL, `nsm` int(11) NOT NULL DEFAULT 0, PRIMARY KEY(`sid`)) DEFAULT CHARSET=utf8mb4";
	//g_hDb.Query(T_nothing, query);

}

public void OnClientPutInServer(int iClient) {
	char sid[32], query[255];
	GetClientAuthId(iClient, AuthId_Steam2, sid, sizeof(sid));

	g_smAdditionalXpOffline.GetValue(sid, g_fAdditionalXpMult[iClient]);

	Format(query, sizeof(query), "SELECT nsm FROM codmod_nsm where sid = '%s'", sid);
	g_iNsm[iClient] = -1;
	g_hDb.Query(T_CheckIfClientExist, query, GetClientSerial(iClient));

}

public void T_CheckIfClientExist(Database db, DBResultSet results, const char[] error, any data) {
	char sid[32];
	int iClient = GetClientFromSerial(data);
	if(iClient == 0 || !(IsClientInGame(iClient)) || IsFakeClient(iClient)) {
		return;
	}
	GetClientAuthId(iClient, AuthId_Steam2, sid, sizeof(sid));
	if(results == null || results.RowCount < 1) {
		char query[255];
		Format(query, sizeof(query), "INSERT INTO codmod_nsm(sid,nsm) VALUES (\"%s\", 0)", sid);
		g_hDb.Query(T_nothing, query);
		g_iNsm[iClient]=0;
	}
	else {
		results.FetchRow();
		g_iNsm[iClient] = results.FetchInt(0);
	}
	g_bLoaded[iClient] = true;
}


public void OnClientDisconnect(int iClient) {
	Db_SavePlayerData(iClient, true);

	/*
		Zapisanie gracza do stringmap, żeby nie stracił bonusu po reconnect
	*/
	char sid[32];
	GetClientAuthId(iClient, AuthId_Steam2, sid, sizeof(sid));
	g_smAdditionalXpOffline.SetArray(sid, g_fAdditionalXpMult[iClient], true);

	g_bLoaded[iClient] = false;
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) {
	int iAttacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int iVictim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(iAttacker == 0 || iAttacker == iVictim)
		return;

	Player_AddNsm(iAttacker);
	PrintToChat(iAttacker, "%s Dostales 1 odlamek!", CHAT_PREFIX);
}

public Action:Event_ZakladnikUratowany(Handle:event, const String:name[], bool:dontbroadcast) {
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	for(new i = 1; i <= MaxClients; i ++) {
		if(!IsClientInGame(i))
			continue;

		if(GetClientTeam(i) != CS_TEAM_CT)
			continue;

		if(i == client) {
			Player_AddNsm(i, 2);
		}
		else {
			Player_AddNsm(i);
		}
	}

	return Plugin_Continue;
}

public Action:Event_BombaRozbrojona(Handle:event, const String:name[], bool:dontbroadcast) {
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	for(new i = 1; i <= MaxClients; i ++) {
		if(!IsClientInGame(i))
			continue;

		if(GetClientTeam(i) != CS_TEAM_CT)
			continue;

		if(i == client) {
			Player_AddNsm(i, 2);
		}
		else {
			Player_AddNsm(i);
		}
	}

	return Plugin_Continue;
}

public Action:Event_BombaPodlozona(Handle:event, const String:name[], bool:dontbroadcast) {
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	for(new i = 1; i <= MaxClients; i ++) {
		if(!IsClientInGame(i))
			continue;

		if(GetClientTeam(i) != CS_TEAM_T)
			continue;

		if(i == client) {
			Player_AddNsm(i, 2);
		} else {
			Player_AddNsm(i);
		}
	}

	return Plugin_Continue;
}

public Action Command_Nsm(int iClient, int iArgs) {
	if(!g_bLoaded[iClient]) {
		PrintToChat(iClient, "%s Nie zostałeś w pełni załadowany!", CHAT_PREFIX);
		return;
	}

	Menu hMenu = new Menu(Menu_Nsm);
	hMenu.SetTitle("Sklep z Nieśmiertelnikami - [%d NŚM]", g_iNsm[iClient]);
	char tmp[128];
	bool bDraw;
	for(int i = 0; i < sizeof(g_iItems); i++) {
		bDraw = true;
		if( (g_iItems[i][Item_Usage] == USAGE_ALIVE && !IsPlayerAlive(iClient)) || (g_iItems[i][Item_Usage] == USAGE_DEATH && IsPlayerAlive(iClient))) {
			bDraw = false;
		}
		Format(tmp, sizeof(tmp), "%s [%d NŚM]", g_iItems[i][Item_Name], g_iItems[i][Item_Price]);
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
		if(Player_GetNsm(iClient) < g_iItems[iOption][Item_Price]) {
			PrintToChat(iClient, "%s Brakuje Ci %d NŚM na zakup %s!", CHAT_PREFIX, g_iItems[iOption][Item_Price] - Player_GetNsm(iClient), g_iItems[iOption][Item_Name]);
			return 0;
		}
		bool continue_sub = true;
		if(g_iItems[iOption][Item_Function] != INVALID_FUNCTION) {
			Call_StartFunction(INVALID_HANDLE, g_iItems[iOption][Item_Function]);
			Call_PushCell(iClient);
			Call_PushCell(iOption);
			Call_Finish(continue_sub);
		}

		if(!continue_sub) {
			return 0;
		}

		Player_SubNsm(iClient, g_iItems[iOption][Item_Price]);

		PrintToChat(iClient, "%s Zakupiles %s!", CHAT_PREFIX, g_iItems[iOption][Item_Name]);
	}

	return 1;
}

/*
	Shop functions
*/
bool Shop_PerkRegen(int iClient, int iOption) {
	if(cod_get_user_item(iClient) < 1)
		return false;
	cod_set_user_item_stamina(iClient, g_iItems[iOption][Item_Params]);
	return true;
}

void Shop_IncreasedXp(int iClient, int iOption) {
	g_fAdditionalXpMult[iClient] += (g_iItems[iOption][Item_Params]/100);
	PrintToConsole(iClient, "Shop_IncreasedXp, %i, %f", iOption, g_fAdditionalXpMult[iClient]);
}

public cod_on_give_exp(int iClient, float &fMult) {
	fMult += g_fAdditionalXpMult[iClient];
}

void Shop_SuperHE(int iClient, int iOption) {
	PrintToConsole(iClient, "Shop_SuperHE, %i", iOption);
}

void Shop_AddXp(int iClient, int iOption) {
	cod_add_user_xp(iClient, g_iItems[iOption][Item_Params]);
}

/*
	Player functions
*/
void Player_AddNsm(int iClient, int iNum = 1) {
	g_iNsm[iClient] += iNum;
}
void Player_SubNsm(int iClient, int iNum) {
	g_iNsm[iClient] -= iNum;
}

int Player_GetNsm(int iClient) {
	return g_iNsm[iClient];
}

int IsValidPlayers()
{
	new gracze;
	for(new i = 1; i <= MaxClients; i ++)
	{
		if(!IsClientInGame(i) || IsFakeClient(i))
			continue;

		gracze ++;
	}

	return gracze;
}

/*
	Database functions
*/

void Db_SavePlayersData() {
	for(int i = 1; i < MAXPLAYERS; i++) {
		if(IsClientInGame(i)) {
			Db_SavePlayerData(i);
		}
	}
}

void Db_SavePlayerData(int iClient, bool bDisconnected = false) {
	if(!g_bLoaded[iClient]) {
		return;
	}
	char sid[32], query[255];
	GetClientAuthId(iClient, AuthId_Steam2, sid, sizeof(sid));
	Format(query, sizeof(query), "UPDATE codmod_nsm SET nsm = %d where sid = \"%s\"", g_iNsm[iClient],sid);
	if(bDisconnected == true) {
		g_iNsm[iClient] = 0;
	}
	g_hDb.Query(T_nothing, query);
}

public void T_nothing(Database db, DBResultSet results, const char[] error, any data) { return; }
