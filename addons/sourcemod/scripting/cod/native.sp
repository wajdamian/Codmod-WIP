public void CreateNatives() {
	CreateNative("cod_set_user_bonus_weapons", Native_UstawBonusoweBronie);
	CreateNative("cod_get_user_bonus_weapons", Native_PobierzBonusoweBronie);

	CreateNative("cod_set_user_bonus_intelligence", Native_UstawBonusowaInteligencje);
	CreateNative("cod_set_user_bonus_health", Native_UstawBonusoweZdrowie);
	CreateNative("cod_set_user_bonus_damage", Native_UstawBonusoweObrazenia);
	CreateNative("cod_set_user_bonus_stamina", Native_UstawBonusowaWytrzymalosc);
	CreateNative("cod_set_user_bonus_trim", Native_UstawBonusowaKondycje);

	CreateNative("cod_get_user_intelligence", Native_PobierzInteligencje);
	CreateNative("cod_get_user_health", Native_PobierzZdrowie);
	CreateNative("cod_get_user_damage", Native_PobierzObrazenia);
	CreateNative("cod_get_user_stamina", Native_PobierzWytrzymalosc);
	CreateNative("cod_get_user_trim", Native_PobierzKondycje);
	CreateNative("cod_get_user_points", Native_PobierzPunkty);

	CreateNative("cod_get_user_maks_intelligence", Native_PobierzMaksymalnaInteligencje);
	CreateNative("cod_get_user_maks_health", Native_PobierzMaksymalneZdrowie);
	CreateNative("cod_get_user_maks_damage", Native_PobierzMaksymalneObrazenia);
	CreateNative("cod_get_user_maks_stamina", Native_PobierzMaksymalnaWytrzymalosc);
	CreateNative("cod_get_user_maks_trim", Native_PobierzMaksymalnaKondycje);

	CreateNative("cod_set_user_xp", Native_UstawDoswiadczenie);
	CreateNative("cod_add_user_xp", Native_DodajDoswiadczenie);
	CreateNative("cod_set_user_class", Native_UstawKlase);
	CreateNative("cod_set_user_item", Native_UstawItem);
	CreateNative("cod_set_user_item_stamina", Native_UstawWytrzymaloscPerku);

	CreateNative("cod_get_user_xp", Native_PobierzDoswiadczenie);
	CreateNative("cod_get_level_xp", Native_PobierzDoswiadczeniePoziomu);
	CreateNative("cod_get_user_level", Native_PobierzPoziom);
	CreateNative("cod_get_user_level_all", Native_PobierzCalkowityPoziom);
	CreateNative("cod_get_user_class", Native_PobierzKlase);
	CreateNative("cod_get_user_item", Native_PobierzItem);
	CreateNative("cod_get_user_item_skill", Native_PobierzWartoscItemu);
	CreateNative("cod_get_user_item_stamina", Native_PobierzWytrzymaloscItemu);

	CreateNative("cod_get_classes_num", Native_PobierzIloscKlas);
	CreateNative("cod_get_classid", Native_PobierzKlasePrzezNazwe);
	CreateNative("cod_get_class_name", Native_PobierzNazweKlasy);
	CreateNative("cod_get_class_desc", Native_PobierzOpisKlasy);
	CreateNative("cod_get_class_weapon", Native_PobierzBronieKlasy);
	CreateNative("cod_get_class_intelligence", Native_PobierzInteligencjeKlasy);
	CreateNative("cod_get_class_health", Native_PobierzZdrowieKlasy);
	CreateNative("cod_get_class_damage", Native_PobierzObrazeniaKlasy);
	CreateNative("cod_get_class_stamina", Native_PobierzWytrzymaloscKlasy);
	CreateNative("cod_get_class_trim", Native_PobierzKondycjeKlasy);
	CreateNative("cod_get_class_flags", Native_PobierzFlagiKlasy);

	CreateNative("cod_get_items_num", Native_PobierzIloscItemow);
	CreateNative("cod_get_itemid", Native_PobierzItemPrzezNazwe);
	CreateNative("cod_get_item_name", Native_PobierzNazweItemu);
	CreateNative("cod_get_item_desc", Native_PobierzOpisItemu);

	CreateNative("cod_inflict_damage", Native_ZadajObrazenia);
	CreateNative("cod_register_class", Native_ZarejestrujKlase);
	CreateNative("cod_register_item", Native_ZarejestrujItem);

	CreateNative("cod_perform_blind", Native_PerformBlind);
}

public Native_PerformBlind(Handle:plugin, numParams)
{
    int iClient = GetNativeCell(1);
    int iMsecs = GetNativeCell(2);
    int iRed = GetNativeCell(3);
    int iGreen = GetNativeCell(4);
    int iBlue = GetNativeCell(5);
    int iAlpha = GetNativeCell(6);

    Player_Blind(iClient, iMsecs, iRed, iGreen, iBlue, iAlpha)
}

public Native_UstawItem(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		UstawNowyItem(client, GetNativeCell(2), GetNativeCell(3), GetNativeCell(4));

	return -1;
}

public Native_PobierzDoswiadczenie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return doswiadczenie_gracza[client];

	return -1;
}



public Native_PobierzDoswiadczeniePoziomu(Handle:plugin, numParams)
{
	return SprawdzDoswiadczenie(GetNativeCell(1));
}

public Native_PobierzPoziom(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return poziom_gracza[client];

	return -1;
}

public Native_PobierzCalkowityPoziom(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new poziom;
		for(new i = 1; i <= ilosc_klas; i ++)
		{
			if(lvl_klasy_gracza[client][i] > poziom)
				poziom = lvl_klasy_gracza[client][i];
		}

		return poziom;
	}

	return -1;
}

public Native_PobierzKlase(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return klasa_gracza[client];

	return -1;
}

public Native_PobierzItem(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return item_gracza[client];

	return -1;
}

public Native_PobierzWartoscItemu(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return wartosc_itemu_gracza[client];

	return -1;
}

public Native_PobierzWytrzymaloscItemu(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return wytrzymalosc_itemu_gracza[client];

	return -1;
}

public Native_PobierzIloscKlas(Handle:plugin, numParams)
{
	if(ilosc_klas)
		return ilosc_klas;

	return -1;
}

public Native_PobierzKlasePrzezNazwe(Handle:plugin, numParams)
{
	new String:nazwa[64];
	GetNativeString(1, nazwa, sizeof(nazwa));
	for(new i = 1; i <= ilosc_klas; i ++)
	{
		if(StrEqual(nazwa, nazwy_klas[i]))
			return i;
	}

	return -1;
}

public Native_PobierzNazweKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
	{
		SetNativeString(2, nazwy_klas[klasa], GetNativeCell(3));
		return 1;
	}

	return -1;
}

public Native_PobierzOpisKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
	{
		SetNativeString(2, opisy_klas[klasa], GetNativeCell(3));
		return 1;
	}

	return -1;
}

public Native_PobierzBronieKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
	{
		SetNativeString(2, bronie_klas[klasa], GetNativeCell(3));
		return 1;
	}

	return 0;
}

public Native_PobierzInteligencjeKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return inteligencja_klas[klasa];

	return -1;
}

public Native_PobierzZdrowieKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return zdrowie_klas[klasa];

	return -1;
}

public Native_PobierzObrazeniaKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return obrazenia_klas[klasa];

	return -1;
}

public Native_PobierzWytrzymaloscKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return wytrzymalosc_klas[klasa];

	return -1;
}

public Native_PobierzKondycjeKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
		return kondycja_klas[klasa];

	return -1;
}

public Native_PobierzFlagiKlasy(Handle:plugin, numParams)
{
	new klasa = GetNativeCell(1);
	if(klasa <= ilosc_klas)
	{
		return flagi_klas[klasa];
	}

	return -1;
}

public Native_PobierzIloscItemow(Handle:plugin, numParams)
{
	if(ilosc_itemow)
		return ilosc_itemow;

	return -1;
}

public Native_PobierzItemPrzezNazwe(Handle:plugin, numParams)
{
	new String:nazwa[64];
	GetNativeString(1, nazwa, sizeof(nazwa));
	for(new i = 1; i <= ilosc_itemow; i ++)
	{
		if(StrEqual(nazwa, nazwy_itemow[i]))
			return i;
	}

	return -1;
}

public Native_PobierzNazweItemu(Handle:plugin, numParams)
{
	new item = GetNativeCell(1);
	if(item <= ilosc_itemow)
	{
		SetNativeString(2, nazwy_itemow[item], GetNativeCell(3));
		return 1;
	}

	return -1;
}

public Native_PobierzOpisItemu(Handle:plugin, numParams)
{
	new item = GetNativeCell(1);
	if(item <= ilosc_itemow)
	{
		SetNativeString(2, opisy_itemow[item], GetNativeCell(3));
		return 1;
	}

	return -1;
}

public Native_ZadajObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	new attacker = GetNativeCell(2);
	new damage = GetNativeCell(3);

	new Handle:data = CreateDataPack();
	WritePackCell(data, client);
	WritePackCell(data, attacker);
	WritePackCell(data, damage);

	CreateTimer(0.0, ZadajObrazenia_Handler, data, TIMER_FLAG_NO_MAPCHANGE);
	return -1;
}

public Action:ZadajObrazenia_Handler(Handle:timer, Handle:data)
{
	ResetPack(data);
	new client = ReadPackCell(data);
	new attacker = ReadPackCell(data);
	new damage = ReadPackCell(data);
	CloseHandle(data);

	if(IsValidClient(client) && IsPlayerAlive(client) && IsValidClient(attacker))
		SDKHooks_TakeDamage(client, attacker, attacker, float(damage), DMG_GENERIC);

	return Plugin_Continue;
}

public Native_ZarejestrujKlase(Handle:plugin, numParams)
{
	if(numParams != 9)
		return -1;

	if(++ilosc_klas > MAKSYMALNA_ILOSC_KLAS)
		return -2;

	pluginy_klas[ilosc_klas] = plugin;
	GetNativeString(1, nazwy_klas[ilosc_klas], sizeof(nazwy_klas[]));
	GetNativeString(2, opisy_klas[ilosc_klas], sizeof(opisy_klas[]));
	GetNativeString(3, bronie_klas[ilosc_klas], sizeof(bronie_klas[]));
	inteligencja_klas[ilosc_klas] = GetNativeCell(4);
	zdrowie_klas[ilosc_klas] = GetNativeCell(5);
	obrazenia_klas[ilosc_klas] = GetNativeCell(6);
	wytrzymalosc_klas[ilosc_klas] = GetNativeCell(7);
	kondycja_klas[ilosc_klas] = GetNativeCell(8);
	flagi_klas[ilosc_klas] = GetNativeCell(9);
	return ilosc_klas;
}

public Native_ZarejestrujItem(Handle:plugin, numParams)
{
	if(numParams != 4)
		return -1;

	if(++ilosc_itemow > MAKSYMALNA_ILOSC_ITEMOW)
		return -2;

	pluginy_itemow[ilosc_itemow] = plugin;
	GetNativeString(1, nazwy_itemow[ilosc_itemow], sizeof(nazwy_itemow[]));
	GetNativeString(2, opisy_itemow[ilosc_itemow], sizeof(opisy_itemow[]));
	min_wartosci_itemow[ilosc_itemow] = GetNativeCell(3);
	max_wartosci_itemow[ilosc_itemow] = GetNativeCell(4);

	return ilosc_itemow;
}

public Native_UstawBonusoweBronie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:nazwa[256];
		GetNativeString(2, nazwa, sizeof(nazwa));
		bonusowe_bronie_gracza[client] = nazwa;
	}

	return -1;
}

public Native_PobierzBonusoweBronie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		SetNativeString(2, bonusowe_bronie_gracza[client], GetNativeCell(3));
		return 1;
	}

	return 0;
}

public Native_UstawBonusowaInteligencje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalna_inteligencja_gracza[client] += (wartosc-bonusowa_inteligencja_gracza[client]);
		bonusowa_inteligencja_gracza[client] = wartosc;
	}

	return -1;
}

public Native_UstawBonusoweZdrowie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalne_zdrowie_gracza[client] += (wartosc-bonusowe_zdrowie_gracza[client])*MNOZNIK_ZYCIA;
		if(IsPlayerAlive(client))
		{
			new zdrowie = GetClientHealth(client)+wartosc*MNOZNIK_ZYCIA;
			SetEntData(client, FindDataMapInfo(client, "m_iHealth"), (zdrowie < 1)? 1: zdrowie);
		}

		bonusowe_zdrowie_gracza[client] = wartosc;
	}

	return -1;
}

public Native_UstawBonusoweObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalne_obrazenia_gracza[client] += float((wartosc-bonusowe_obrazenia_gracza[client]));
		bonusowe_obrazenia_gracza[client] = wartosc;
	}

	return -1;
}

public Native_UstawBonusowaWytrzymalosc(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalna_wytrzymalosc_gracza[client] += float((wartosc-bonusowa_wytrzymalosc_gracza[client]));
		bonusowa_wytrzymalosc_gracza[client] = wartosc;
	}

	return -1;
}

public Native_UstawBonusowaKondycje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wartosc = GetNativeCell(2);
		maksymalna_kondycja_gracza[client] += float((wartosc-bonusowa_kondycja_gracza[client]))*MNOZNIK_KONDYCJI;
		if(IsPlayerAlive(client))
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", maksymalna_kondycja_gracza[client]);

		bonusowa_kondycja_gracza[client] = wartosc;
	}

	return -1;
}

public Native_PobierzInteligencje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new inteligencja;
		if(GetNativeCell(2))
			inteligencja += inteligencja_gracza[client];
		if(GetNativeCell(3))	
			inteligencja += bonusowa_inteligencja_gracza[client];
		if(GetNativeCell(4))
			inteligencja += inteligencja_klas[klasa_gracza[client]];

		return inteligencja;
	}

	return -1;
}

public Native_PobierzZdrowie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new zdrowie;
		if(GetNativeCell(2))	
			zdrowie += zdrowie_gracza[client];
		if(GetNativeCell(3))
			zdrowie += bonusowe_zdrowie_gracza[client];
		if(GetNativeCell(4))	
			zdrowie += zdrowie_klas[klasa_gracza[client]];

		return zdrowie;
	}

	return -1;
}

public Native_PobierzObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new obrazenia;
		if(GetNativeCell(2))
			obrazenia += obrazenia_gracza[client];
		if(GetNativeCell(3))
			obrazenia += bonusowe_obrazenia_gracza[client];
		if(GetNativeCell(4))
			obrazenia += obrazenia_klas[klasa_gracza[client]];

		return obrazenia;
	}

	return -1;
}

public Native_PobierzWytrzymalosc(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new wytrzymalosc;
		if(GetNativeCell(2))
			wytrzymalosc += wytrzymalosc_gracza[client];
		if(GetNativeCell(3))
			wytrzymalosc += bonusowa_wytrzymalosc_gracza[client];
		if(GetNativeCell(4))
			wytrzymalosc += wytrzymalosc_klas[klasa_gracza[client]];

		return wytrzymalosc;
	}

	return -1;
}

public Native_PobierzKondycje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new kondycja;
		if(GetNativeCell(2))
			kondycja += kondycja_gracza[client];
		if(GetNativeCell(3))
			kondycja += bonusowa_kondycja_gracza[client];
		if(GetNativeCell(4))
			kondycja += kondycja_klas[klasa_gracza[client]];

		return kondycja;
	}

	return -1;
}

public Native_PobierzPunkty(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return punkty_gracza[client];

	return -1;
}

public Native_PobierzMaksymalnaInteligencje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return maksymalna_inteligencja_gracza[client];

	return -1;
}

public Native_PobierzMaksymalneZdrowie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		return maksymalne_zdrowie_gracza[client];

	return -1;
}

public Native_PobierzMaksymalneObrazenia(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:obrazenia[10];
		FloatToString(maksymalne_obrazenia_gracza[client], obrazenia, sizeof(obrazenia));

		SetNativeString(2, obrazenia, GetNativeCell(3));
		return 1;
	}

	return -1;
}

public Native_PobierzMaksymalnaWytrzymalosc(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:wytrzymalosc[10];
		FloatToString(maksymalna_wytrzymalosc_gracza[client], wytrzymalosc, sizeof(wytrzymalosc));

		SetNativeString(2, wytrzymalosc, GetNativeCell(3));
		return 1;
	}

	return -1;
}

public Native_PobierzMaksymalnaKondycje(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		new String:kondycja[10];
		FloatToString(maksymalna_kondycja_gracza[client], kondycja, sizeof(kondycja));

		SetNativeString(2, kondycja, GetNativeCell(3));
		return 1;
	}

	return -1;
}

public Native_DodajDoswiadczenie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		DodajDoswiadczenie(client, GetNativeCell(2));

	return -1;
}

public Native_UstawDoswiadczenie(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
		UstawNoweDoswiadczenie(client, GetNativeCell(2));

	return -1;
}

public Native_UstawKlase(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client))
	{
		nowa_klasa_gracza[client] = GetNativeCell(2);
		if(GetNativeCell(3))
		{
			UstawNowaKlase(client);
			DajBronie(client);
			ZastosujAtrybuty(client);
		}
	}

	return -1;
}

public Native_UstawWytrzymaloscPerku(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if(IsValidClient(client)) {
		UstawWytrzymaloscPerku(client, GetNativeCell(2));
	}
}