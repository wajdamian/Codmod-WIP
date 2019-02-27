public void HookEvents() {
	HookEvent("round_freeze_end", Event_PoczatekRundy);
	HookEvent("round_start", Event_NowaRunda);
	HookEvent("round_end", Event_KoniecRundy);

	HookEvent("hostage_rescued", Event_ZakladnikUratowany);
	HookEvent("bomb_defused", Event_BombaRozbrojona);
	HookEvent("bomb_planted", Event_BombaPodlozona);

	HookEvent("player_spawn", Event_OdrodzenieGracza);
	HookEvent("player_death", Event_SmiercGracza);

	HookEvent("item_purchase", Event_KupowanieBroni, EventHookMode_Post);
	AddNormalSoundHook(DzwiekiGracza);
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(client) || !IsValidClient(attacker))
		return Plugin_Continue;

	if(GetClientTeam(client) == GetClientTeam(attacker))
		return Plugin_Continue;

	if(klasa_gracza[attacker])
	{
		new doswiadczenie_za_obrazenia = GetConVarInt(cvar_doswiadczenie_za_obrazenia);
		if(doswiadczenie_za_obrazenia)
		{
			new wartosc_obrazen = 20;
			new obrazenia = RoundFloat(damage);
			if(obrazenia >= wartosc_obrazen)
			{
				new doswiadczenie = doswiadczenie_za_obrazenia*(obrazenia/wartosc_obrazen);
				DodajDoswiadczenie(attacker, doswiadczenie);
			}
		}
	}

	damage = (damage+(maksymalne_obrazenia_gracza[attacker]/4))*(1.0-(maksymalna_wytrzymalosc_gracza[client]/300));
	return Plugin_Changed;
}

public Action:Event_KupowanieBroni(Handle:event, const String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;

	new String:weapon[32];
	GetEventString(event, "weapon", weapon, sizeof(weapon));

	if (StrEqual(nazwy_klas[klasa_gracza[client]], "El Pistolero", false))
	{
		for(new i = 0; i < sizeof(bronie_elpistolero); i ++)
		{
			if(StrEqual(bronie_elpistolero[i], weapon))
				return Plugin_Continue;
		}
	}

	if (StrEqual(nazwy_klas[klasa_gracza[client]], "Specjalista [P]", false))
	{
		for(new i = 0; i < sizeof(bronie_specjalisty); i ++)
		{
			if(StrEqual(bronie_specjalisty[i], weapon))
				return Plugin_Continue;
		}
	}

	if ((StrEqual(nazwy_klas[klasa_gracza[client]], "Najemnik", false)) && !StrEqual(weapon, "weapon_xm1014", false) && !StrEqual(weapon, "weapon_scar20", false) && !StrEqual(weapon, "weapon_g3sg1", false))
	return Plugin_Continue;

	PrintToChat(client, "Nie mozesz kupic tej broni!");
	return Plugin_Handled;
}

public Action:WeaponCanUse(client, weapon)
{
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;

	new String:weapons[32];
	GetEdictClassname(weapon, weapons, sizeof(weapons));
	new weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	switch(weaponindex)
	{
		case 23: strcopy(weapons, sizeof(weapons), "weapon_mp5sd");
		case 60: strcopy(weapons, sizeof(weapons), "weapon_m4a1_silencer");
		case 61: strcopy(weapons, sizeof(weapons), "weapon_usp_silencer");
		case 63: strcopy(weapons, sizeof(weapons), "weapon_cz75a");
		case 64: strcopy(weapons, sizeof(weapons), "weapon_revolver");
	}

	new String:weaponsclass[10][32];
	ExplodeString(bronie_klas[klasa_gracza[client]], "#", weaponsclass, sizeof(weaponsclass), sizeof(weaponsclass[]));
	for(new i = 0; i < sizeof(weaponsclass); i ++)
	{
		if(StrEqual(weaponsclass[i], weapons))
			return Plugin_Continue;
	}

	new String:weaponsbonus[5][32];
	ExplodeString(bonusowe_bronie_gracza[client], "#", weaponsbonus, sizeof(weaponsbonus), sizeof(weaponsbonus[]));
	for(new i = 0; i < sizeof(weaponsbonus); i ++)
	{
		if(StrEqual(weaponsbonus[i], weapons))
			return Plugin_Continue;
	}

	for(new i = 0; i < sizeof(bronie_dozwolone); i ++)
	{
		if(StrEqual(bronie_dozwolone[i], weapons))
			return Plugin_Continue;
	}

	for (new i = 0; i < sizeof(bronie_specjalisty); i++)
	{
		if (StrEqual(bronie_specjalisty[i], weapons))
			return Plugin_Continue;
	}
	
	if (StrEqual(nazwy_klas[klasa_gracza[client]], "El Pistolero"))
	{
		for(new i = 0; i < sizeof(bronie_elpistolero); i ++)
		{
			if(StrEqual(bronie_elpistolero[i], weapons))
				return Plugin_Continue;
		}
	}

	if ((StrEqual(nazwy_klas[klasa_gracza[client]], "Najemnik", false)) && !StrEqual(weapons, "weapon_xm1014", false) && !StrEqual(weapons, "weapon_scar20", false) && !StrEqual(weapons, "weapon_g3sg1", false))
	return Plugin_Continue;

	AcceptEntityInput(weapon, "Kill");
	return Plugin_Handled;
}

public Action:Event_PoczatekRundy(Handle:event, const String:name[], bool:dontbroadcast)
{
	freezetime = false;
}

public Action:Event_NowaRunda(Handle:event, const String:name[], bool:dontbroadcast)
{
	freezetime = true;
}

public Action:Event_KoniecRundy(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_wygrana_runde = GetConVarInt(cvar_doswiadczenie_za_wygrana_runde);
	if(doswiadczenie_za_wygrana_runde)
	{
		new wygrana_druzyna = GetEventInt(event, "winner");
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != ((wygrana_druzyna == 2)? CS_TEAM_T: CS_TEAM_CT))
				continue;

			if(IsPlayerAlive(i))
			{
				DodajDoswiadczenie(i, doswiadczenie_za_wygrana_runde);
				PrintToChat(i, "Dostales %i doswiadczenia za wygranie rundy.", doswiadczenie_za_wygrana_runde);
			}
			else
			{
				DodajDoswiadczenie(i, doswiadczenie_za_wygrana_runde/2);
				PrintToChat(i, "Dostales %i doswiadczenia za wygranie rundy przez twoja druzyne.", doswiadczenie_za_wygrana_runde/2);
			}
		}
	}

	return Plugin_Continue;
}

public Action:Event_ZakladnikUratowany(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_cele_mapy = GetConVarInt(cvar_doswiadczenie_za_cele_mapy);
	if(doswiadczenie_za_cele_mapy)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != CS_TEAM_CT)
				continue;

			if(i == client)
			{
				DodajDoswiadczenie(i, doswiadczenie_za_cele_mapy);
				PrintToChat(i, "Dostales %i doswiadczenia za uratowanie zakladnika.", doswiadczenie_za_cele_mapy);
			}
			else
			{
				DodajDoswiadczenie(i, doswiadczenie_za_cele_mapy/2);
				PrintToChat(i, "Dostales %i doswiadczenia za uratowanie zakladnika przez twoja druzyne.", doswiadczenie_za_cele_mapy/2);
			}
		}
	}

	return Plugin_Continue;
}

public Action:Event_BombaRozbrojona(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_cele_mapy = GetConVarInt(cvar_doswiadczenie_za_cele_mapy);
	if(doswiadczenie_za_cele_mapy)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != CS_TEAM_CT)
				continue;

			if(i == client)
			{
				DodajDoswiadczenie(i, doswiadczenie_za_cele_mapy);
				PrintToChat(i, "Dostales %i doswiadczenia za rozbrojenie bomby.", doswiadczenie_za_cele_mapy);
			}
			else
			{
				DodajDoswiadczenie(i, doswiadczenie_za_cele_mapy/2);
				PrintToChat(i, "Dostales %i doswiadczenia za rozbrojenie bomby przez twoja druzyne.", doswiadczenie_za_cele_mapy/2);
			}
		}
	}

	return Plugin_Continue;
}

public Action:Event_BombaPodlozona(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(IsValidPlayers() < MINIMALNA_ILOSC_GRACZY)
		return Plugin_Continue;

	new doswiadczenie_za_cele_mapy = GetConVarInt(cvar_doswiadczenie_za_cele_mapy);
	if(doswiadczenie_za_cele_mapy)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		for(new i = 1; i <= MaxClients; i ++)
		{
			if(!IsClientInGame(i) || !klasa_gracza[i])
				continue;

			if(GetClientTeam(i) != CS_TEAM_T)
				continue;

			if(i == client)
			{
				DodajDoswiadczenie(i, doswiadczenie_za_cele_mapy);
				PrintToChat(i, "Dostales %i doswiadczenia za podlozenie bomby.", doswiadczenie_za_cele_mapy);
			}
			else
			{
				DodajDoswiadczenie(i, doswiadczenie_za_cele_mapy);
				PrintToChat(i, "Dostales %i doswiadczenia za podlozenie bomby przez twoja druzyne.", doswiadczenie_za_cele_mapy/2);
			}
		}
	}

	return Plugin_Continue;
}

public Action:Event_OdrodzenieGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return Plugin_Continue;

	if(hud_task[client] == null)
		hud_task[client] = CreateTimer(0.5, PokazInformacje, client, TIMER_FLAG_NO_MAPCHANGE);

	if(zapis_task[client] == null)
		zapis_task[client] = CreateTimer(30.0, ZapiszDane, GetClientSerial(client), TIMER_FLAG_NO_MAPCHANGE);

	if(nowa_klasa_gracza[client])
		UstawNowaKlase(client);

	if(!klasa_gracza[client])
		Command_WybierzKlase(client, 0);
	else if(punkty_gracza[client])
		Command_PrzydzielPunkty(client, 0);

	ZastosujAtrybuty(client);
	DajBronie(client);

	return Plugin_Continue;
}

public Action:Event_SmiercGracza(Handle:event, String:name[], bool:dontbroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new killer = GetClientOfUserId(GetEventInt(event, "attacker"));
	new bool:headshot = GetEventBool(event, "headshot");
	if(!IsValidClient(client) || !IsValidClient(killer))
		return Plugin_Continue;

	if(klasa_gracza[killer] && GetClientTeam(client) != GetClientTeam(killer))
	{
		if(headshot)
		{
			new doswiadczenie_za_zabojstwo_hs = GetConVarInt(cvar_doswiadczenie_za_zabojstwo_hs);
			if(doswiadczenie_za_zabojstwo_hs)
			{
				DodajDoswiadczenie(killer, doswiadczenie_za_zabojstwo_hs);
				PrintToChat(killer, "Dostales %i doswiadczenia za zabicie przeciwnika headshotem.", doswiadczenie_za_zabojstwo_hs);
			}
		}
		else
		{
			new doswiadczenie_za_zabojstwo = GetConVarInt(cvar_doswiadczenie_za_zabojstwo);
			if(doswiadczenie_za_zabojstwo)
			{
				DodajDoswiadczenie(killer, doswiadczenie_za_zabojstwo);
				PrintToChat(killer, "Dostales %i doswiadczenia za zabicie przeciwnika.", doswiadczenie_za_zabojstwo);
			}
		}
		if(!item_gracza[killer])
		{
			UstawNowyItem(killer, -1, -1, -1);
			PrintToChat(killer, "Zdobyles %s.", nazwy_itemow[item_gracza[killer]]);
		}
	}

	new wytrzymalosc_itemow = GetConVarInt(cvar_wytrzymalosc_itemow);
	if(wytrzymalosc_itemow && wytrzymalosc_itemu_gracza[client])
	{
		if(wytrzymalosc_itemu_gracza[client] > wytrzymalosc_itemow)
			wytrzymalosc_itemu_gracza[client] -= wytrzymalosc_itemow;
		else
		{
			UstawNowyItem(client, 0, 0, 0);
			PrintToChat(client, "Twoj perk ulegl zniszczeniu.");
		}
	}

	return Plugin_Continue;
}

public Action:DzwiekiGracza(clients[64], &numclients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if(!IsValidClient(entity) || IsFakeClient(entity))
		return Plugin_Continue;

	if((StrContains(sample, "physics") != -1 || StrContains(sample, "footsteps") != -1) && StrContains(sample, "suit") == -1)
	{
		if(StrEqual(nazwy_klas[klasa_gracza[entity]], "Szpieg",false) || StrEqual(nazwy_klas[klasa_gracza[entity]], "Klekotnik Jadowity [Dev]", false) || StrEqual(nazwy_itemow[item_gracza[entity]], "Puchowe Buty", false) || StrEqual(nazwy_itemow[item_gracza[entity]], "Podrecznik Szpiega", false))
			return Plugin_Handled;
		EmitSoundToAll(sample, entity);
		return Plugin_Handled;
	}

	return Plugin_Continue;
}