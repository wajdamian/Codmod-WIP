#include <sourcemod>
#include <sdkhooks>
#include <codmod>
#include <sdktools>

new const String:nazwa[] = "Obronca";
new const String:opis[] = "Stawia 3 worki, odporny na miny i rakiety";
new const String:bronie[] = "#weapon_negev#weapon_glock#weapon_molotov";
new const inteligencja = 0;
new const zdrowie = 20;
new const obrazenia = 0;
new const wytrzymalosc = 5;
new const kondycja = 0;
new const flagi = 0;

new bool:ma_klase[65];
new ilosc_workow_gracza[65];

public Plugin:myinfo =
{
	name = nazwa,
	author = "de duk goos quak m8",
	description = "Obronca",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
	HookEvent("player_spawn", OdrodzenieGracza);
}
public OnMapStart()
{	
	AddFileToDownloadsTable("models/codmod/worki/worki.mdl");
	AddFileToDownloadsTable("models/codmod/worki/worki.dx90.vtx");
	AddFileToDownloadsTable("models/codmod/worki/worki.phy");	
	AddFileToDownloadsTable("models/codmod/worki/worki.vvd");
	
	AddFileToDownloadsTable("materials/codmod/worki/skin1.vmt");
	AddFileToDownloadsTable("materials/codmod/worki/skin1.vtf");
	AddFileToDownloadsTable("materials/codmod/worki/skin2.vmt");
	AddFileToDownloadsTable("materials/codmod/worki/skin2.vtf");
	
	PrecacheModel("models/codmod/worki/worki.mdl");
}

public cod_class_enabled(client)
{
	ma_klase[client] = true;
	ilosc_workow_gracza[client] = 3;
} 
public cod_class_disabled(client)
{
	ma_klase[client] = false;
}

public Action:OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client) || !ma_klase[client])
		return Plugin_Continue;
	
	ilosc_workow_gracza[client] = 3;
	return Plugin_Continue;
}

public cod_class_skill_used(client)
{
	if (ma_klase[client] && IsPlayerAlive(client) && ilosc_workow_gracza[client] > 0)
	{
		new ent = CreateEntityByName("prop_physics_override");
		if(ent != -1)
		{
			new Float:forigin[3], Float:fangles[3], Float:fdistance;
			GetClientEyePosition(client, forigin);
			GetClientEyeAngles(client, fangles);
			new Float:iorigin[3], Float:ivector[3];
			
			TR_TraceRayFilter(forigin, fangles, MASK_PLAYERSOLID, RayType_Infinite, FilterPlayers, client);
			TR_GetEndPosition(iorigin);
			MakeVectorFromPoints(forigin, iorigin, ivector);
			new Float:tpVector[3];
			AddVectors(forigin, ivector, tpVector);
			fdistance = GetVectorDistance(forigin, tpVector);
			if ( fdistance > 400.0)
			{
				return;
			}
			SetEntityModel(ent, "models/codmod/worki/worki.mdl");
			DispatchKeyValue(ent, "spawnflags", "3");
			DispatchSpawn(ent);
			AcceptEntityInput(ent, "DisableMotion");
			SetEntityMoveType(ent, MOVETYPE_NONE);	
			SetEntProp(ent, Prop_Data, "m_takedamage", 2);
			SetEntProp(ent, Prop_Data, "m_iHealth", 1500);
			
			iorigin[2] +=20;
			fangles[0] = 0.0;
			TeleportEntity(ent, iorigin,fangles, NULL_VECTOR);
			ilosc_workow_gracza[client]--;
		}
	}
	if (ilosc_workow_gracza[client] == 0)
		PrintToChat(client, "Zuzyles juz wszystkie worki w tej rundzie!");
}

public bool:FilterPlayers(entity, contentsMask)
{
	return !(1 <= entity <= MaxClients);
}