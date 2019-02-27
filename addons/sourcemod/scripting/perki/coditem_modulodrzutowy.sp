#include <sourcemod>
#include <sdktools>
#include <codmod>

new const String:nazwa[] = "Moduł Odrzutowy";
new const String:opis[] = "Posiadasz LongJumpa(codmod_perk) co 4 sekundy";

new bool:perkReady[65];
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
	perkReady[client] = true;
}
public cod_item_disabled(client)
{
	ma_item[client] = false;
}
public cod_item_used(client)
{
	if (perkReady[client] && ma_item[client])
	{
		new Float:forigin[3];
		GetClientEyePosition(client, forigin);

		new Float:fangles[3];
		GetClientEyeAngles(client, fangles);
		new Float:iorigin[3], Float:iangles[3], Float:ivector[3];
		TR_TraceRayFilter(forigin, fangles, MASK_SOLID, RayType_Infinite, TraceRayFilter, client);
		TR_GetEndPosition(iorigin);
		MakeVectorFromPoints(forigin, iorigin, ivector);
		NormalizeVector(ivector, ivector);
		ScaleVector(ivector, 1000.0);
		GetVectorAngles(ivector, iangles);
		ivector[2]-=ivector[2];
		ivector[2]+=300;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, ivector);
		perkReady[client] = false;
		CreateTimer(4.0, perkRenewal, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}
public bool:TraceRayFilter(ent, contents)
{
	return false;
}
public Action:perkRenewal(Handle:timer, any:client)
{
	if (!ma_item[client])
		return Plugin_Stop;
	perkReady[client] = true;
	PrintToChat(client, "[COD] Perk nie jest jeszcze gotowy do użytku!");
	return Plugin_Continue;
}