#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <cstrike>

#define PLUGIN_NAME "Call of Duty Mod"
#define PLUGIN_VERSION "1.3"
#define PLUGIN_AUTHOR "Zerciu, de duk goos quak m8"
#define PLUGIN_DESCRIPTION "Plugin oparty na kodzie QTM_Peyote za błogosławieństwiem Th7ndera"
#define PLUGIN_URL "http://steamcommunity.com/id/Zerciu https://steamcommunity.com/profiles/76561198145991535"

#define MAKSYMALNA_WARTOSC_ZMIENNEJ 99999
#define MAKSYMALNA_ILOSC_KLAS 100
#define MAKSYMALNA_ILOSC_ITEMOW 120
#define MINIMALNA_ILOSC_GRACZY 4

#define MNOZNIK_ZYCIA 2
#define MNOZNIK_KONDYCJI 0.004

#include "cod/var.sp"
#include "cod/misc.sp"
#include "cod/event.sp"
#include "cod/sql.sp"
#include "cod/command.sp"
#include "cod/native.sp"
#include "cod/cvar.sp"

public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

public OnPluginStart()
{
	CreateCvars();
	RegisterCommands();
	HookEvents();

	forward_OnGiveExp = CreateGlobalForward("cod_on_give_exp", ET_Ignore, Param_Cell, Param_FloatByRef);
	forward_OnPlayerBlind = CreateGlobalForward("cod_on_player_blind", ET_Event, Param_Cell, Param_CellByRef);

	HookUserMessage(GetUserMessageId("TextMsg"), TextMessage, true);
	LoadTranslations("common.phrases");

	nazwy_klas[0] = "Brak";
	opisy_klas[0] = "Brak dodatkowych uzdolnien";
	bronie_klas[0] = "";
	inteligencja_klas[0] = 0;
	zdrowie_klas[0] = -49;
	obrazenia_klas[0] = 0;
	wytrzymalosc_klas[0] = 0;
	kondycja_klas[0] = 0;

	nazwy_itemow[0] = "Brak";
	opisy_itemow[0] = "Zabij kogos lub kup losowy perk poprzez /sklep";
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNatives();
}

public OnMapStart()
{
	AddFileToDownloadsTable("sound/cod/levelup.mp3");
	AutoExecConfig(true, "codmod");
	DataBaseConnect();
}

public OnClientAuthorized(client)
{
	UsunUmiejetnosci(client);
	UsunZadania(client);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, WeaponCanUse);
	if(!IsFakeClient(client))
		SendConVarValue(client, FindConVar("sv_footsteps"), "0");

	WczytajDane(client);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_WeaponCanUse, WeaponCanUse);

	ZapiszDane_Handler(client);
	UsunUmiejetnosci(client);
	UsunZadania(client);
}