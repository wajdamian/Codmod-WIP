public void RegisterCommands() {
	RegConsoleCmd("sm_klasa", Command_WybierzKlase);
	RegConsoleCmd("sm_class", Command_WybierzKlase);
	RegConsoleCmd("sm_klasy", Command_OpisKlas);
	RegConsoleCmd("sm_classinfo", Command_OpisKlas);
	RegConsoleCmd("sm_items", Command_OpisItemow);
	RegConsoleCmd("sm_perks", Command_OpisItemow);
	RegConsoleCmd("sm_perki", Command_OpisItemow);
	RegConsoleCmd("sm_item", Command_OpisItemu);
	RegConsoleCmd("sm_perk", Command_OpisItemu);
	RegConsoleCmd("sm_p", Command_OpisItemu);
	RegConsoleCmd("sm_wyrzuc", Command_WyrzucItem);
	RegConsoleCmd("sm_d", Command_WyrzucItem);
	RegConsoleCmd("sm_drop", Command_WyrzucItem);
	RegConsoleCmd("sm_useclass", Command_UzyjKlasy);
	RegConsoleCmd("codmod_skill", Command_UzyjKlasy);
	RegConsoleCmd("sm_useperk", Command_UzyjItemu);
	RegConsoleCmd("codmod_perk", Command_UzyjItemu);
	RegConsoleCmd("sm_statystyki", Command_PrzydzielPunkty);
	RegConsoleCmd("sm_staty", Command_PrzydzielPunkty);
	RegConsoleCmd("sm_reset", Command_ResetujPunkty);
	RegConsoleCmd("sm_dajperk", Command_DajPerk);
	/*
	RegConsoleCmd("buy", Command_BlokujKomende);
	RegConsoleCmd("buyequip", Command_BlokujKomende);
	RegConsoleCmd("buyammo1", Command_BlokujKomende);
	RegConsoleCmd("buyammo2", Command_BlokujKomende);
	RegConsoleCmd("rebuy", Command_BlokujKomende);
	RegConsoleCmd("autobuy", Command_BlokujKomende);
	*/
}

public Action:Command_WybierzKlase(client, args)
{
	if(wczytane_dane[client])
	{
		lvl_klasy_gracza[client][klasa_gracza[client]] = poziom_gracza[client];
		xp_klasy_gracza[client][klasa_gracza[client]] = doswiadczenie_gracza[client];
		int_klasy_gracza[client][klasa_gracza[client]] = inteligencja_gracza[client];
		zdr_klasy_gracza[client][klasa_gracza[client]] = zdrowie_gracza[client];
		obr_klasy_gracza[client][klasa_gracza[client]] = obrazenia_gracza[client];
		wyt_klasy_gracza[client][klasa_gracza[client]] = wytrzymalosc_gracza[client];
		kon_klasy_gracza[client][klasa_gracza[client]] = kondycja_gracza[client];

		new String:menu_item[128];
		new Handle:menu = CreateMenu(WybierzKlase_Handler);
		SetMenuTitle(menu, "Wybierz Klase:");
		for(new i = 1; i <= ilosc_klas; i ++)
		{
			Format(menu_item, sizeof(menu_item), "%s (Lv: %i)", nazwy_klas[i], lvl_klasy_gracza[client][i]);
			AddMenuItem(menu, "", menu_item);
		}

		DisplayMenu(menu, client, 250);
	}
	else
		PrintToChat(client, "Trwa wczytywanie twoich danych!");

	return Plugin_Handled;
}
public WybierzKlase_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		new String:item[32];
		new String:szSteamID[32];
		GetClientAuthId(client, AuthId_Steam2, szSteamID, sizeof(szSteamID));
		
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;
		if ((GetUserFlagBits(client) & flagi_klas[position] != flagi_klas[position]) && flagi_klas[position] != 0)
		{
			PrintToChat(client, "Nie możesz wybrać tej klasy premium, dostęp do niej możesz kupić w naszym sklepie na (Allan please add shop url)");
			return;
		}
		if (!StrEqual(szSteamID, "STEAM_1:1:92862903", false) && StrEqual(nazwy_klas[position], "Klekotnik Jadowity [Dev]", false))
		{
			PrintToChat(client, "Ta klasa jest zarezerwowana dla developera.");
			return;
		}
		if (!StrEqual(szSteamID, "STEAM_1:0:28686758", false) && StrEqual(nazwy_klas[position], "Cytrynowy Alchemik [Dev]", false))
		{
			PrintToChat(client, "Ta klasa jest zarezerwowana dla developera.");
			return;
		}
		
		if(position == klasa_gracza[client] && !nowa_klasa_gracza[client])
			return;

		nowa_klasa_gracza[client] = position;
		if(klasa_gracza[client])
			PrintToChat(client, "Klasa zostanie zmieniona w nastepnej rundzie.");
		else
		{
			UstawNowaKlase(client);
			ZastosujAtrybuty(client);
			DajBronie(client);
		}
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:Command_OpisKlas(client, args)
{
	new Handle:menu = CreateMenu(OpisKlas_Handler);
	SetMenuTitle(menu, "Wybierz Klase:");
	for(new i = 1; i <= ilosc_klas; i ++)
		AddMenuItem(menu, "", nazwy_klas[i]);

	DisplayMenu(menu, client, 250);
	return Plugin_Handled;
}
public OpisKlas_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		new String:item[32];
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;

		new String:bronie[512];
		Format(bronie, sizeof(bronie), "%s", bronie_klas[position]);
		ReplaceString(bronie, sizeof(bronie), "#weapon_", "|");

		new String:opis[1024];
		new Function:forward_klasy = GetFunctionByName(pluginy_klas[position], "cod_class_skill_used");
		if(forward_klasy != INVALID_FUNCTION)
			Format(opis, sizeof(opis), "Klasa: %s\nInteligencja: %i\nZdrowie: %i\nObrazenia: %i\nWytrzymalosc: %i\nKondycja: %i\nBronie: %s\nOpis: %s\nUzycie Umiejetnosci: codmod_skill", nazwy_klas[position], inteligencja_klas[position], zdrowie_klas[position], obrazenia_klas[position], wytrzymalosc_klas[position], kondycja_klas[position], bronie, opisy_klas[position]);
		else
			Format(opis, sizeof(opis), "Klasa: %s\nInteligencja: %i\nZdrowie: %i\nObrazenia: %i\nWytrzymalosc: %i\nKondycja: %i\nBronie: %s\nOpis: %s", nazwy_klas[position], inteligencja_klas[position], zdrowie_klas[position], obrazenia_klas[position], wytrzymalosc_klas[position], kondycja_klas[position], bronie, opisy_klas[position]);

		new Handle:menu = CreateMenu(OpisKlas2_Handler);
		SetMenuTitle(menu, opis);
		AddMenuItem(menu, "", "Lista Klas");
		DisplayMenu(menu, client, 250);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public OpisKlas2_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
		Command_OpisKlas(client, 0);
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:Command_OpisItemow(client, args)
{
	new Handle:menu = CreateMenu(OpisItemow_Handler);
	SetMenuTitle(menu, "Wybierz Perk:");
	for(new i = 1; i <= ilosc_itemow; i ++)
		AddMenuItem(menu, "", nazwy_itemow[i]);

	DisplayMenu(menu, client, 250);
	return Plugin_Handled;
}
public OpisItemow_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		new String:item[32];
		GetMenuItem(classhandle, position, item, sizeof(item));
		position ++;

		new String:opis_itemu[128];
		new String:losowa_wartosc[21];
		Format(losowa_wartosc, sizeof(losowa_wartosc), "%i-%i", min_wartosci_itemow[position], max_wartosci_itemow[position]);
		Format(opis_itemu, sizeof(opis_itemu), opisy_itemow[position]);
		ReplaceString(opis_itemu, sizeof(opis_itemu), "LW", losowa_wartosc);

		new String:opis[512];
		new Function:forward_itemu = GetFunctionByName(pluginy_itemow[position], "cod_item_used");
		if(forward_itemu != INVALID_FUNCTION)
			Format(opis, sizeof(opis), "Perk: %s\nOpis: %s\nUzycie: codmod_perk", nazwy_itemow[position], opis_itemu);
		else
			Format(opis, sizeof(opis), "Perk: %s\nOpis: %s", nazwy_itemow[position], opis_itemu);

		new Handle:menu = CreateMenu(OpisItemow_Handler2);
		SetMenuTitle(menu, opis);
		AddMenuItem(menu, "", "Lista Itemow");
		DisplayMenu(menu, client, 250);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public OpisItemow_Handler2(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
		Command_OpisItemow(client, 0);
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:Command_OpisItemu(client, args)
{
	new String:opis_itemu[128];
	new String:losowa_wartosc[10];
	IntToString(wartosc_itemu_gracza[client], losowa_wartosc, sizeof(losowa_wartosc));
	Format(opis_itemu, sizeof(opis_itemu), opisy_itemow[item_gracza[client]]);
	ReplaceString(opis_itemu, sizeof(opis_itemu), "LW", losowa_wartosc);

	PrintToChat(client, "Perk: %s (%i%%).", nazwy_itemow[item_gracza[client]], wytrzymalosc_itemu_gracza[client]);
	PrintToChat(client, "Opis: %s.", opis_itemu);

	new Function:forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[client]], "cod_item_used");
	if(forward_itemu != INVALID_FUNCTION)
		PrintToChat(client, "Uzycie Umiejetnosci: Useitem.");

	return Plugin_Handled;
}
public Action:Command_WyrzucItem(client, args)
{
	if(item_gracza[client])
	{
		UstawNowyItem(client, 0, 0, 0);
		PrintToChat(client, "Wyrzuciles swoj item.");
	}
	else
		PrintToChat(client, "Nie posiadasz zadnego itemu.");

	return Plugin_Handled;
}
public Action:Command_UzyjKlasy(client, args)
{
	if(!(!IsPlayerAlive(client) || freezetime))
	{
		new Function:forward_klasy = GetFunctionByName(pluginy_klas[klasa_gracza[client]], "cod_class_skill_used");
		if(forward_klasy != INVALID_FUNCTION)
		{
			Call_StartFunction(pluginy_klas[klasa_gracza[client]], forward_klasy);
			Call_PushCell(client);
			Call_PushCell(klasa_gracza[client]);
			Call_Finish();
		}
	}

	return Plugin_Handled;
}
public Action:Command_UzyjItemu(client, args)
{
	if(!(!IsPlayerAlive(client) || freezetime))
	{
		new Function:forward_itemu = GetFunctionByName(pluginy_itemow[item_gracza[client]], "cod_item_used");
		if(forward_itemu != INVALID_FUNCTION)
		{
			Call_StartFunction(pluginy_itemow[item_gracza[client]], forward_itemu);
			Call_PushCell(client);
			Call_PushCell(item_gracza[client]);
			Call_Finish();
		}
	}

	return Plugin_Handled;
}
public Action:Command_PrzydzielPunkty(client, args)
{
	new proporcja_punktow = GetConVarInt(cvar_proporcja_punktow);
	if(!proporcja_punktow)
		return Plugin_Continue;

	new limit_inteligencji = GetConVarInt(cvar_limit_inteligencji);
	if(!limit_inteligencji)
		limit_inteligencji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_zdrowia = GetConVarInt(cvar_limit_zdrowia);
	if(!limit_zdrowia)
		limit_zdrowia = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_obrazen = GetConVarInt(cvar_limit_obrazen);
	if(!limit_obrazen)
		limit_obrazen = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_wytrzymalosci = GetConVarInt(cvar_limit_wytrzymalosci);
	if(!limit_wytrzymalosci)
		limit_wytrzymalosci = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	new limit_kondycji = GetConVarInt(cvar_limit_kondycji);
	if(!limit_kondycji)
		limit_kondycji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

	if(inteligencja_gracza[client] > limit_inteligencji || zdrowie_gracza[client] > limit_zdrowia || obrazenia_gracza[client] > limit_obrazen || wytrzymalosc_gracza[client] > limit_wytrzymalosci || kondycja_gracza[client] > limit_kondycji)
		Command_ResetujPunkty(client, 0);
	else
	{
		new String:opis[128];
		new Handle:menu = CreateMenu(PrzydzielPunkty_Handler);

		Format(opis, sizeof(opis), "Przydziel Punkty (%i):", punkty_gracza[client]);
		SetMenuTitle(menu, opis);

		if(punkty_statystyk[rozdane_punkty_gracza[client]] == -1)
			Format(opis, sizeof(opis), "Ile dodawac: ALL (Po ile punktow dodawac do statystyk)");
		else
			Format(opis, sizeof(opis), "Ile dodawac: %i (Po ile punktow dodawac do statystyk)", punkty_statystyk[rozdane_punkty_gracza[client]]);

		AddMenuItem(menu, "1", opis);

		Format(opis, sizeof(opis), "Inteligencja: %i/%i (Zwieksza sile itemow i umiejetnosci klas)", inteligencja_gracza[client], limit_inteligencji);
		AddMenuItem(menu, "2", opis);

		Format(opis, sizeof(opis), "Zdrowie: %i/%i (Zwieksza zdrowie)", zdrowie_gracza[client], limit_zdrowia);
		AddMenuItem(menu, "3", opis);

		Format(opis, sizeof(opis), "Obrazenia: %i/%i (Zwieksza zadawane obrazenia)", obrazenia_gracza[client], limit_obrazen);
		AddMenuItem(menu, "4", opis);

		Format(opis, sizeof(opis), "Wytrzymalosc: %i/%i (Zmniejsza otrzymywane obrazenia)", wytrzymalosc_gracza[client], limit_wytrzymalosci);
		AddMenuItem(menu, "5", opis);

		Format(opis, sizeof(opis), "Kondycja: %i/%i (Zwieksza tempo chodu)", kondycja_gracza[client], limit_kondycji);
		AddMenuItem(menu, "6", opis);

		DisplayMenu(menu, client, 250);
	}

	return Plugin_Handled;
}
public PrzydzielPunkty_Handler(Handle:classhandle, MenuAction:action, client, position)
{
	if(action == MenuAction_Select)
	{
		if(!punkty_gracza[client])
			return;

		new String:item[32];
		GetMenuItem(classhandle, position, item, sizeof(item));

		new wartosc;
		if(punkty_statystyk[rozdane_punkty_gracza[client]] == -1)
			wartosc = punkty_gracza[client];
		else
			wartosc = (punkty_statystyk[rozdane_punkty_gracza[client]] > punkty_gracza[client])? punkty_gracza[client]: punkty_statystyk[rozdane_punkty_gracza[client]];

		if(StrEqual(item, "1"))
		{
			if(rozdane_punkty_gracza[client] < sizeof(punkty_statystyk)-1)
				rozdane_punkty_gracza[client] ++;
			else
				rozdane_punkty_gracza[client] = 0;
		}
		else if(StrEqual(item, "2"))
		{
			new limit_inteligencji = GetConVarInt(cvar_limit_inteligencji);
			if(!limit_inteligencji)
				limit_inteligencji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(inteligencja_gracza[client] < limit_inteligencji)
			{
				if(inteligencja_gracza[client]+wartosc <= limit_inteligencji)
				{
					zdobyta_inteligencja_gracza[client] += wartosc;
					inteligencja_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_inteligencji-inteligencja_gracza[client];
					zdobyta_inteligencja_gracza[client] += punktydodania;
					inteligencja_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, "Osiagnales juz maksymalny poziom inteligencji!");
		}
		else if(StrEqual(item, "3"))
		{
			new limit_zdrowia = GetConVarInt(cvar_limit_zdrowia);
			if(!limit_zdrowia)
				limit_zdrowia = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(zdrowie_gracza[client] < limit_zdrowia)
			{
				if(zdrowie_gracza[client]+wartosc <= limit_zdrowia)
				{
					zdobyte_zdrowie_gracza[client] += wartosc;
					zdrowie_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_zdrowia-zdrowie_gracza[client];
					zdobyte_zdrowie_gracza[client] += punktydodania;
					zdrowie_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, "Osiagnales juz maksymalny poziom zdrowia!");
		}
		else if(StrEqual(item, "4"))
		{
			new limit_obrazen = GetConVarInt(cvar_limit_obrazen);
			if(!limit_obrazen)
				limit_obrazen = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(obrazenia_gracza[client] < limit_obrazen)
			{
				if(obrazenia_gracza[client]+wartosc <= limit_obrazen)
				{
					zdobyte_obrazenia_gracza[client] += wartosc;
					obrazenia_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_obrazen-obrazenia_gracza[client];
					zdobyte_obrazenia_gracza[client] += punktydodania;
					obrazenia_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, "Osiagnales juz maksymalny poziom obrazen!");
		}
		else if(StrEqual(item, "5"))
		{
			new limit_wytrzymalosci = GetConVarInt(cvar_limit_wytrzymalosci);
			if(!limit_wytrzymalosci)
				limit_wytrzymalosci = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(wytrzymalosc_gracza[client] < limit_wytrzymalosci)
			{
				if(wytrzymalosc_gracza[client]+wartosc <= limit_wytrzymalosci)
				{
					zdobyta_wytrzymalosc_gracza[client] += wartosc;
					wytrzymalosc_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_wytrzymalosci-wytrzymalosc_gracza[client];
					zdobyta_wytrzymalosc_gracza[client] += punktydodania;
					wytrzymalosc_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, "Osiagnales juz maksymalny poziom wytrzymalosci!");
		}
		else if(StrEqual(item, "6"))
		{
			new limit_kondycji = GetConVarInt(cvar_limit_kondycji);
			if(!limit_kondycji)
				limit_kondycji = MAKSYMALNA_WARTOSC_ZMIENNEJ;

			if(kondycja_gracza[client] < limit_kondycji)
			{
				if(kondycja_gracza[client]+wartosc <= limit_kondycji)
				{
					zdobyta_kondycja_gracza[client] += wartosc;
					kondycja_gracza[client] += wartosc;
					punkty_gracza[client] -= wartosc;
				}
				else
				{
					new punktydodania;
					punktydodania = limit_kondycji-kondycja_gracza[client];
					zdobyta_kondycja_gracza[client] += punktydodania;
					kondycja_gracza[client] += punktydodania;
					punkty_gracza[client] -= punktydodania;
				}
			}
			else
				PrintToChat(client, "Osiagnales juz maksymalny poziom kondycji!");
		}
		if(punkty_gracza[client])
			Command_PrzydzielPunkty(client, 0);
	}
	else if(action == MenuAction_End)
		CloseHandle(classhandle);
}
public Action:Command_DajPerk(client, args)
{
	new String:nazwaItemu[64];
	GetCmdArg(1, nazwaItemu, sizeof(nazwaItemu));
	new itemID = 0;
	for(new i = 1; i <= ilosc_itemow; i ++)
	{
		if(StrEqual(nazwy_itemow[i], nazwaItemu, false))
		{
			itemID = i;
			break;
		}
	}
	UstawNowyItem(client, itemID, -1, -1);
}
public Action:Command_ResetujPunkty(client, args)
{
	zdobyta_inteligencja_gracza[client] -= inteligencja_gracza[client];
	inteligencja_gracza[client] = 0;

	zdobyte_zdrowie_gracza[client] -= zdrowie_gracza[client];
	zdrowie_gracza[client] = 0;

	zdobyte_obrazenia_gracza[client] -= obrazenia_gracza[client];
	obrazenia_gracza[client] = 0;

	zdobyta_wytrzymalosc_gracza[client] -= wytrzymalosc_gracza[client];
	wytrzymalosc_gracza[client] = 0;

	zdobyta_kondycja_gracza[client] -= kondycja_gracza[client];
	kondycja_gracza[client] = 0;

	punkty_gracza[client] = (GetConVarInt(cvar_proporcja_punktow) < 1)? 0: (poziom_gracza[client]*GetConVarInt(cvar_proporcja_punktow))-inteligencja_gracza[client]-zdrowie_gracza[client]-obrazenia_gracza[client]-wytrzymalosc_gracza[client]-kondycja_gracza[client];
	if(punkty_gracza[client])
		Command_PrzydzielPunkty(client, 0);

	PrintToChat(client, "Umiejetnosci zostaly zresetowane.");
	return Plugin_Handled;
}
public Action:Command_BlokujKomende(client, args)
{
	return Plugin_Handled;
}