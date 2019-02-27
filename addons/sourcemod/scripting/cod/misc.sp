public Action:SprawdzPoziom(client)
{
	if(!klasa_gracza[client])
		return Plugin_Continue;

	new bool:zdobyty_poziom = false;
	new bool:stracony_poziom = false;
	new limit_poziomu = GetConVarInt(cvar_limit_poziomu);
	if(!limit_poziomu)
		limit_poziomu = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	while(doswiadczenie_gracza[client] >= SprawdzDoswiadczenie(poziom_gracza[client]) && poziom_gracza[client] < limit_poziomu)
	{
		zdobyty_poziom_gracza[client] ++;
		poziom_gracza[client] ++;
		zdobyty_poziom = true;
	}
	while(doswiadczenie_gracza[client] < SprawdzDoswiadczenie(poziom_gracza[client]-1))
	{
		zdobyty_poziom_gracza[client] --;
		poziom_gracza[client] --;
		stracony_poziom = true;
	}
	if(poziom_gracza[client] > limit_poziomu)
	{
		zdobyty_poziom_gracza[client] -= (poziom_gracza[client]-limit_poziomu);
		poziom_gracza[client] = limit_poziomu;
		stracony_poziom = true;
	}
	if(stracony_poziom)
		Command_ResetujPunkty(client, 0);
	else if(zdobyty_poziom)
	{
		punkty_gracza[client] = (GetConVarInt(cvar_proporcja_punktow) < 1)? 0: (poziom_gracza[client]*GetConVarInt(cvar_proporcja_punktow))-inteligencja_gracza[client]-zdrowie_gracza[client]-obrazenia_gracza[client]-wytrzymalosc_gracza[client]-kondycja_gracza[client];
		ClientCommand(client, "play *cod/levelup.mp3");
	}

	return Plugin_Continue;
}

public Action:UsunUmiejetnosci(client)
{
	for(new i = 0; i <= ilosc_klas; i ++)
	{
		lvl_klasy_gracza[client][i] = 1;
		xp_klasy_gracza[client][i] = 0;
		int_klasy_gracza[client][i] = 0;
		zdr_klasy_gracza[client][i] = 0;
		obr_klasy_gracza[client][i] = 0;
		wyt_klasy_gracza[client][i] = 0;
		kon_klasy_gracza[client][i] = 0;
	}

	wczytane_dane[client] = false;
	rozdane_punkty_gracza[client] = 0;

	bonusowe_bronie_gracza[client] = "";
	bonusowa_inteligencja_gracza[client] = 0;
	bonusowe_zdrowie_gracza[client] = 0;
	bonusowe_obrazenia_gracza[client] = 0;
	bonusowa_wytrzymalosc_gracza[client] = 0;
	bonusowa_kondycja_gracza[client] = 0;

	nowa_klasa_gracza[client] = 0;
	UstawNowaKlase(client);
	UstawNowyItem(client, 0, 0, 0);
}
public Action:UsunZadania(client)
{
	if(hud_task[client] != null)
	{
		KillTimer(hud_task[client]);
		hud_task[client] = null;
	}
	if(zapis_task[client] != null)
	{
		KillTimer(zapis_task[client]);
		zapis_task[client] = null;
	}
}

public Action:ZastosujAtrybuty(client)
{
	if(!IsPlayerAlive(client))
		return Plugin_Continue;

	maksymalna_inteligencja_gracza[client] = (inteligencja_gracza[client]+bonusowa_inteligencja_gracza[client]+inteligencja_klas[klasa_gracza[client]]);
	maksymalne_zdrowie_gracza[client] = 100+(zdrowie_gracza[client]+(bonusowe_zdrowie_gracza[client]+zdrowie_klas[klasa_gracza[client]]))*MNOZNIK_ZYCIA;
	maksymalne_obrazenia_gracza[client] = (obrazenia_gracza[client]+bonusowe_obrazenia_gracza[client]+obrazenia_klas[klasa_gracza[client]])*1.0;
	maksymalna_wytrzymalosc_gracza[client] = (wytrzymalosc_gracza[client]+bonusowa_wytrzymalosc_gracza[client]+wytrzymalosc_klas[klasa_gracza[client]])*1.0;
	maksymalna_kondycja_gracza[client] = 1.0+(kondycja_gracza[client]+bonusowa_kondycja_gracza[client]+kondycja_klas[klasa_gracza[client]])*MNOZNIK_KONDYCJI;

	SetEntData(client, FindDataMapInfo(client, "m_iHealth"), maksymalne_zdrowie_gracza[client]);
	SetEntData(client, FindDataMapInfo(client, "m_iMaxHealth"), maksymalne_zdrowie_gracza[client]);
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", maksymalna_kondycja_gracza[client]);

	SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
	return Plugin_Continue;
}

public Action:DajBronie(client)
{
	if(!IsPlayerAlive(client))
		return Plugin_Continue;

	new ent = -1;
	for(new slot = 0; slot < 4; slot ++)
	{
		if(slot == 2)
			continue;

		ent = GetPlayerWeaponSlot(client, slot);
		if(ent != -1)
			RemovePlayerItem(client, ent);
	}

	new String:weapons[10][32];
	ExplodeString(bronie_klas[klasa_gracza[client]], "#", weapons, sizeof(weapons), sizeof(weapons[]));
	for(new i = 0; i < sizeof(weapons); i ++)
	{
		if(!StrEqual(weapons[i], ""))
			GivePlayerItem(client, weapons[i]);
	}

	new String:weapons2[5][32];
	ExplodeString(bonusowe_bronie_gracza[client], "#", weapons2, sizeof(weapons2), sizeof(weapons2[]));
	for(new i = 0; i < sizeof(weapons2); i ++)
	{
		if(!StrEqual(weapons2[i], ""))
			GivePlayerItem(client, weapons2[i]);
	}
	
	return Plugin_Continue;
}



public Action:PokazInformacje(Handle:timer, any:client)
{
	if(!IsValidClient(client))
		return;

	if(IsPlayerAlive(client))
		PrintHintText(client, "<font color='#008000'>[Klasa: <b>%s</b>]\n</font><font color='#080000'>[Xp: <b>%i</b> | Poziom: <b>%i</b>]\n</font><font color='#000080'>[Item: <b>%s</b> [<b>%i%%</b>]]</font>", nazwy_klas[klasa_gracza[client]], doswiadczenie_gracza[client], poziom_gracza[client], nazwy_itemow[item_gracza[client]], wytrzymalosc_itemu_gracza[client]);
	else
	{
		new spect = GetEntProp(client, Prop_Send, "m_iObserverMode");
		if(spect == 4 || spect == 5) 
		{
			new target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if(target != -1 && IsValidClient(target))
				PrintHintText(client, "<font color='##BD11E0'>[Klasa: <b>%s</b>]\n[Xp: <b>%i</b> | Poziom: <b>%i</b>]\n[Item: <b>%s</b> [<b>%i%%</b>]]</font>", nazwy_klas[klasa_gracza[target]], doswiadczenie_gracza[target], poziom_gracza[target], nazwy_itemow[item_gracza[target]], wytrzymalosc_itemu_gracza[target]);
		}
	}

	hud_task[client] = CreateTimer(0.5, PokazInformacje, client, TIMER_FLAG_NO_MAPCHANGE);
}



public void DodajDoswiadczenie(client, doswiadczenie)
{
	float multiplier = 1.0;
	Call_StartForward(forward_OnGiveExp);
	Call_PushCell(client);
	Call_PushFloatRef(multiplier);
	Call_Finish();

	doswiadczenie = RoundToFloor(multiplier*doswiadczenie);
	UstawNoweDoswiadczenie(client, doswiadczenie_gracza[client]+doswiadczenie);
}

public Action:UstawNoweDoswiadczenie(client, doswiadczenie)
{
	new nowe_doswiadczenie = doswiadczenie-doswiadczenie_gracza[client];
	zdobyte_doswiadczenie_gracza[client] += nowe_doswiadczenie;
	doswiadczenie_gracza[client] = nowe_doswiadczenie+doswiadczenie_gracza[client];

	SprawdzPoziom(client);
	return Plugin_Continue;
}



public Action:UstawNowaKlase(client)
{
	if(!ilosc_klas)
		return Plugin_Continue;

	new Function:forward_klasy;
	forward_klasy = GetFunctionByName(pluginy_klas[klasa_gracza[client]], "cod_class_disabled");
	if(forward_klasy != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_klas[klasa_gracza[client]], forward_klasy);
		Call_PushCell(client);
		Call_PushCell(klasa_gracza[client]);
		Call_Finish();
	}

	new ret;
	forward_klasy = GetFunctionByName(pluginy_klas[nowa_klasa_gracza[client]], "cod_class_enabled");
	if(forward_klasy != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_klas[nowa_klasa_gracza[client]], forward_klasy);
		Call_PushCell(client);
		Call_PushCell(nowa_klasa_gracza[client]);
		Call_Finish(ret);
	}
	if(ret == 4)
	{
		nowa_klasa_gracza[client] = klasa_gracza[client];
		UstawNowaKlase(client);
		return Plugin_Continue;
	}

	ZapiszDane_Handler(client);
	klasa_gracza[client] = nowa_klasa_gracza[client];
	nowa_klasa_gracza[client] = 0;
	ZmienDane(client);

	UstawNowyItem(client, item_gracza[client], wartosc_itemu_gracza[client], wytrzymalosc_itemu_gracza[client]);
	return Plugin_Continue;
}

public Action:UstawNowyItem(client, item, wartosc, wytrzymalosc)
{
	if(!ilosc_itemow)
		return Plugin_Continue;

	new limit_wytrzymalosci_itemu = GetConVarInt(cvar_max_wytrzymalosc_itemow);
	if(!limit_wytrzymalosci_itemu)
		limit_wytrzymalosci_itemu = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	item = (item < 0 || item > ilosc_itemow)? GetRandomInt(1, ilosc_itemow): item;
	wartosc = (wartosc < min_wartosci_itemow[item] || wartosc > max_wartosci_itemow[item])? GetRandomInt(min_wartosci_itemow[item], max_wartosci_itemow[item]): wartosc;
	wytrzymalosc = (wytrzymalosc < 0 || wytrzymalosc > limit_wytrzymalosci_itemu)? limit_wytrzymalosci_itemu: wytrzymalosc;

	new Function:forward_itemu;
	forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[client]], "cod_item_disabled");
	if(forward_itemu != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_itemow[item_gracza[client]], forward_itemu);
		Call_PushCell(client);
		Call_PushCell(item_gracza[client]);
		Call_Finish();
	}

	new ret;
	forward_itemu = GetFunctionByName(pluginy_itemow[item], "cod_item_enabled");
	if(forward_itemu != INVALID_FUNCTION)
	{
		Call_StartFunction(pluginy_itemow[item], forward_itemu);
		Call_PushCell(client);
		Call_PushCell(wartosc);
		Call_PushCell(item);
		Call_Finish(ret);
	}

	item_gracza[client] = item;
	wartosc_itemu_gracza[client] = wartosc;
	wytrzymalosc_itemu_gracza[client] = wytrzymalosc;
	if(ret == 4)
		UstawNowyItem(client, -1, -1, -1);

	return Plugin_Continue;
}

public UstawWytrzymaloscPerku(client, wartosc) {
	wytrzymalosc_itemu_gracza[client] = wartosc <= GetConVarInt(cvar_max_wytrzymalosc_itemow) ? wartosc : GetConVarInt(cvar_max_wytrzymalosc_itemow);
}

public SprawdzDoswiadczenie(poziom)
{
	new proporcja_poziomu = GetConVarInt(cvar_proporcja_poziomu);
	if(!proporcja_poziomu)
		proporcja_poziomu = 1;

	return RoundFloat(Pow(float(poziom), 2.0))*proporcja_poziomu;
}

public Action:TextMessage(UserMsg:msg_text, Handle:pb, const players[], playersNum, bool:reliable, bool:init)
{
	if(!reliable || PbReadInt(pb, "msg_dst") != 3)
		return Plugin_Continue;

	new String:buffer[256];
	PbReadString(pb, "params", buffer, sizeof(buffer), 0);
	if(StrContains(buffer, "#Player_Cash_Award_") == 0 || StrContains(buffer, "#Team_Cash_Award_") == 0)
		return Plugin_Handled;

	return Plugin_Continue;
}

public bool:IsValidClient(client)
{
	if(client >= 1 && client <= MaxClients && IsClientInGame(client))
		return true;

	return false;
}

public IsValidPlayers()
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

public void Player_Blind(int iClient, int iMsecs, int iRed, int iGreen, int iBlue, int iAlpha){
    Action aResult;
    Call_StartForward(forward_OnPlayerBlind);
    Call_PushCell(iClient);
    Call_PushCellRef(iMsecs);
    Call_Finish(aResult);
    if(aResult == Plugin_Stop || aResult == Plugin_Handled) {
        return;
    }
    int iColor[4];
    iColor[0] = iRed;
    iColor[1] = iGreen;
    iColor[2] = iBlue;
    iColor[3] = iAlpha;
    Handle hFadeClient = StartMessageOne("Fade", iClient)
    PbSetInt(hFadeClient, "duration", 100);
    PbSetInt(hFadeClient, "hold_time", iMsecs);
    PbSetInt(hFadeClient, "flags", (0x0010|0x0002));
    PbSetColor(hFadeClient, "clr", iColor);
    EndMessage();
}