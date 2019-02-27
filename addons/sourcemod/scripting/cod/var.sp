new Handle:sql,
	Handle:hud_task[65],
	Handle:zapis_task[65],
	Handle:cvar_doswiadczenie_za_zabojstwo,
	Handle:cvar_doswiadczenie_za_zabojstwo_hs,
	Handle:cvar_doswiadczenie_za_obrazenia,
	Handle:cvar_doswiadczenie_za_wygrana_runde,
	Handle:cvar_doswiadczenie_za_cele_mapy,
	Handle:cvar_limit_poziomu,
	Handle:cvar_proporcja_poziomu,
	Handle:cvar_proporcja_punktow,
	Handle:cvar_limit_inteligencji,
	Handle:cvar_limit_zdrowia,
	Handle:cvar_limit_obrazen,
	Handle:cvar_limit_wytrzymalosci,
	Handle:cvar_limit_kondycji,
	Handle:cvar_wytrzymalosc_itemow,
	Handle:cvar_max_wytrzymalosc_itemow,
	bool:freezetime,
	Handle:forward_OnGiveExp;
	Handle:forward_OnPlayerBlind;

new bool:wczytane_dane[65],
	nowa_klasa_gracza[65],
	klasa_gracza[65],
	zdobyty_poziom_gracza[65],
	poziom_gracza[65],
	zdobyte_doswiadczenie_gracza[65],
	doswiadczenie_gracza[65],
	item_gracza[65],
	wartosc_itemu_gracza[65],
	wytrzymalosc_itemu_gracza[65];

new rozdane_punkty_gracza[65],
	punkty_gracza[65],
	zdobyta_inteligencja_gracza[65],
	inteligencja_gracza[65],
	zdobyte_zdrowie_gracza[65],
	zdrowie_gracza[65],
	zdobyte_obrazenia_gracza[65],
	obrazenia_gracza[65],
	zdobyta_wytrzymalosc_gracza[65],
	wytrzymalosc_gracza[65],
	zdobyta_kondycja_gracza[65],
	kondycja_gracza[65];

new String:bonusowe_bronie_gracza[65][256],
	bonusowa_inteligencja_gracza[65],
	bonusowe_zdrowie_gracza[65],
	bonusowe_obrazenia_gracza[65],
	bonusowa_wytrzymalosc_gracza[65],
	bonusowa_kondycja_gracza[65];

new maksymalna_inteligencja_gracza[65],
	maksymalne_zdrowie_gracza[65],
	Float:maksymalne_obrazenia_gracza[65],
	Float:maksymalna_wytrzymalosc_gracza[65],
	Float:maksymalna_kondycja_gracza[65];

new lvl_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	xp_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	int_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	zdr_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	obr_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	wyt_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1],
	kon_klasy_gracza[65][MAKSYMALNA_ILOSC_KLAS+1];

new String:nazwy_klas[MAKSYMALNA_ILOSC_KLAS+1][64],
	String:opisy_klas[MAKSYMALNA_ILOSC_KLAS+1][128],
	String:bronie_klas[MAKSYMALNA_ILOSC_KLAS+1][512],
	inteligencja_klas[MAKSYMALNA_ILOSC_KLAS+1], 
	zdrowie_klas[MAKSYMALNA_ILOSC_KLAS+1],
	obrazenia_klas[MAKSYMALNA_ILOSC_KLAS+1],
	wytrzymalosc_klas[MAKSYMALNA_ILOSC_KLAS+1],
	kondycja_klas[MAKSYMALNA_ILOSC_KLAS+1],
	flagi_klas[MAKSYMALNA_ILOSC_KLAS+1],
	Handle:pluginy_klas[MAKSYMALNA_ILOSC_KLAS+1],
	ilosc_klas;

new String:nazwy_itemow[MAKSYMALNA_ILOSC_ITEMOW+1][64],
	String:opisy_itemow[MAKSYMALNA_ILOSC_ITEMOW+1][128],
	max_wartosci_itemow[MAKSYMALNA_ILOSC_ITEMOW+1],
	min_wartosci_itemow[MAKSYMALNA_ILOSC_ITEMOW+1],
	Handle:pluginy_itemow[MAKSYMALNA_ILOSC_ITEMOW+1],
	ilosc_itemow;

new String:bronie_dozwolone[][] = {"weapon_c4", "weapon_knife", "weapon_knife_widowmaker", "weapon_knife_stiletto", "weapon_knife_gypsy_jackknife", "weapon_knife_ursus", "weapon_knife_push", "weapon_knife_butterfly", "weapon_knife_survival_bowie", "weapon_knife_falchion", "weapon_knife_tactical", "weapon_knife_m9_bayonet", "weapon_knife_karambit", "weapon_knife_gut", "weapon_knife_flip", "weapon_bayonet"},
	punkty_statystyk[] = {1, 10, -1},
	String:bronie_elpistolero[][] = {"weapon_glock", "weapon_elite", "weapon_p250", "weapon_tec9", "weapon_cz75a", "weapon_deagle", "weapon_revolver", "weapon_usp_silencer", "weapon_hkp2000", "weapon_fiveseven"};
	String:bronie_specjalisty[][] = {"weapon_hegrenade","weapon_flashbang","weapon_smokegrenade","weapon_molotov","weapon_decoy","weapon_incgrenade"};
