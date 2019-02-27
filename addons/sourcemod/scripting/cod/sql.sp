public Action:DataBaseConnect()
{
	new String:error[128];
	sql = SQL_Connect("717309_codmodsql", true, error, sizeof(error));
	if(sql == INVALID_HANDLE)
	{
		LogError("Could not connect: %s", error);
		return Plugin_Continue;
	}

	new String:zapytanie[1024];
	Format(zapytanie, sizeof(zapytanie), "CREATE TABLE IF NOT EXISTS `codmod` (`authid` VARCHAR(48) NOT NULL, `klasa` VARCHAR(64) NOT NULL, `poziom` INT UNSIGNED NOT NULL DEFAULT 1, `doswiadczenie` INT UNSIGNED NOT NULL DEFAULT 1, PRIMARY KEY(`authid`, `klasa`), ");
	StrCat(zapytanie, sizeof(zapytanie), "`inteligencja` INT UNSIGNED NOT NULL DEFAULT 0, `zdrowie` INT UNSIGNED NOT NULL DEFAULT 0, `obrazenia` INT UNSIGNED NOT NULL DEFAULT 0, `wytrzymalosc` INT UNSIGNED NOT NULL DEFAULT 0, `kondycja` INT UNSIGNED NOT NULL DEFAULT 0)");

	SQL_LockDatabase(sql);
	SQL_FastQuery(sql, zapytanie);
	SQL_UnlockDatabase(sql);

	return Plugin_Continue;
}

public Action:ZapiszDane(Handle:timer, any:serial)
{
	new client = GetClientFromSerial(serial);
	if(!IsValidClient(client))
		return Plugin_Continue;

	ZapiszDane_Handler(client);
	zapis_task[client] = CreateTimer(30.0, ZapiszDane, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action:ZapiszDane_Handler(client)
{
	if(IsFakeClient(client) || !klasa_gracza[client] || !wczytane_dane[client])
		return Plugin_Continue;

	new String:authid[64];
	GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

	new String:zapytanie[1024];
	Format(zapytanie, sizeof(zapytanie), "UPDATE `codmod` SET `poziom` = (`poziom` + '%i'), `doswiadczenie` = (`doswiadczenie` + '%i'), `inteligencja` = (`inteligencja` + '%i'), `zdrowie` = (`zdrowie` + '%i'), `obrazenia` = (`obrazenia` + '%i'), `wytrzymalosc` = (`wytrzymalosc` + '%i'), `kondycja` = (`kondycja` + '%i') WHERE `authid` = '%s' AND `klasa` = '%s'",
	zdobyty_poziom_gracza[client], zdobyte_doswiadczenie_gracza[client], zdobyta_inteligencja_gracza[client], zdobyte_zdrowie_gracza[client], zdobyte_obrazenia_gracza[client], zdobyta_wytrzymalosc_gracza[client], zdobyta_kondycja_gracza[client], authid, nazwy_klas[klasa_gracza[client]]);
	SQL_TQuery(sql, HandleIgnore, zapytanie, client);

	zdobyty_poziom_gracza[client] = 0;
	lvl_klasy_gracza[client][klasa_gracza[client]] = poziom_gracza[client];

	zdobyte_doswiadczenie_gracza[client] = 0;
	xp_klasy_gracza[client][klasa_gracza[client]] = doswiadczenie_gracza[client];

	zdobyta_inteligencja_gracza[client] = 0;
	int_klasy_gracza[client][klasa_gracza[client]] = inteligencja_gracza[client];

	zdobyte_zdrowie_gracza[client] = 0;
	zdr_klasy_gracza[client][klasa_gracza[client]] = zdrowie_gracza[client];

	zdobyte_obrazenia_gracza[client] = 0;
	obr_klasy_gracza[client][klasa_gracza[client]] = obrazenia_gracza[client];

	zdobyta_wytrzymalosc_gracza[client] = 0;
	wyt_klasy_gracza[client][klasa_gracza[client]] = wytrzymalosc_gracza[client];

	zdobyta_kondycja_gracza[client] = 0;
	kon_klasy_gracza[client][klasa_gracza[client]] = kondycja_gracza[client];

	return Plugin_Continue;
}

public Action:WczytajDane(client)
{
	if(IsClientSourceTV(client))
		return Plugin_Continue;

	if(IsFakeClient(client))
	{
		wczytane_dane[client] = true;
		return Plugin_Continue;
	}

	new String:authid[64];
	GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

	new String:zapytanie[512];
	Format(zapytanie, sizeof(zapytanie), "SELECT `klasa`, `poziom`, `doswiadczenie`, `inteligencja`, `zdrowie`, `obrazenia`, `wytrzymalosc`, `kondycja` FROM `codmod` WHERE `authid` = '%s'", authid);
	SQL_TQuery(sql, WczytajDane_Handler, zapytanie, GetClientSerial(client));

	return Plugin_Continue;
}

public WczytajDane_Handler(Handle:owner, Handle:query, const String:error[], any:serial)
{
	new client = GetClientFromSerial(serial);
	if(!IsValidClient(client))
		return

	if(query == INVALID_HANDLE)
	{
		LogError("Load error: %s", error);
		return;
	}
	if(SQL_GetRowCount(query))
	{
		new String:klasa[64];
		while(SQL_MoreRows(query))
		{
			while(SQL_FetchRow(query))
			{
				SQL_FetchString(query, 0, klasa, sizeof(klasa));
				for(new i = 1; i <= ilosc_klas; i ++)
				{
					if(!StrEqual(nazwy_klas[i], klasa))
						continue;

					lvl_klasy_gracza[client][i] = SQL_FetchInt(query, 1);
					xp_klasy_gracza[client][i] = SQL_FetchInt(query, 2);
					int_klasy_gracza[client][i] = SQL_FetchInt(query, 3);
					zdr_klasy_gracza[client][i] = SQL_FetchInt(query, 4);
					obr_klasy_gracza[client][i] = SQL_FetchInt(query, 5);
					wyt_klasy_gracza[client][i] = SQL_FetchInt(query, 6);
					kon_klasy_gracza[client][i] = SQL_FetchInt(query, 7);
					break;
				}
			}
		}
	}

	wczytane_dane[client] = true;
}

public Action:ZmienDane(client)
{
	zdobyty_poziom_gracza[client] = 0;
	poziom_gracza[client] = lvl_klasy_gracza[client][klasa_gracza[client]];

	zdobyte_doswiadczenie_gracza[client] = 0;
	doswiadczenie_gracza[client] = xp_klasy_gracza[client][klasa_gracza[client]];

	zdobyta_inteligencja_gracza[client] = 0;
	inteligencja_gracza[client] = int_klasy_gracza[client][klasa_gracza[client]];

	zdobyte_zdrowie_gracza[client] = 0;
	zdrowie_gracza[client] = zdr_klasy_gracza[client][klasa_gracza[client]];

	zdobyte_obrazenia_gracza[client] = 0;
	obrazenia_gracza[client] = obr_klasy_gracza[client][klasa_gracza[client]];

	zdobyta_wytrzymalosc_gracza[client] = 0;
	wytrzymalosc_gracza[client] = wyt_klasy_gracza[client][klasa_gracza[client]];

	zdobyta_kondycja_gracza[client] = 0;
	kondycja_gracza[client] = kon_klasy_gracza[client][klasa_gracza[client]];

	punkty_gracza[client] = (GetConVarInt(cvar_proporcja_punktow) < 1)? 0: (poziom_gracza[client]*GetConVarInt(cvar_proporcja_punktow))-inteligencja_gracza[client]-zdrowie_gracza[client]-obrazenia_gracza[client]-wytrzymalosc_gracza[client]-kondycja_gracza[client];
	if(!IsFakeClient(client) && wczytane_dane[client] && klasa_gracza[client] && !doswiadczenie_gracza[client])
	{
		new String:authid[64];
		GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));

		new String:zapytanie[512];
		Format(zapytanie, sizeof(zapytanie), "INSERT INTO `codmod` (`authid`, `klasa`) VALUES ('%s', '%s')", authid, nazwy_klas[klasa_gracza[client]]);
		SQL_TQuery(sql, HandleIgnore, zapytanie, client);
		UstawNoweDoswiadczenie(client, doswiadczenie_gracza[client]+1);
	}

	return Plugin_Continue;
}

public HandleIgnore(Handle:owner, Handle:query, const String:error[], any:client)
{
	if(query == INVALID_HANDLE)
	{
		LogError("Save error: %s", error);
		return;
	}
}