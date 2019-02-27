public void CreateCvars() {
	CreateConVar(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	cvar_doswiadczenie_za_zabojstwo = CreateConVar("cod_xp_kill", "10");
	cvar_doswiadczenie_za_zabojstwo_hs = CreateConVar("cod_xp_killhs", "15");
	cvar_doswiadczenie_za_obrazenia = CreateConVar("cod_xp_damage", "1");
	cvar_doswiadczenie_za_wygrana_runde = CreateConVar("cod_xp_winround", "25");
	cvar_doswiadczenie_za_cele_mapy = CreateConVar("cod_xp_objectives", "50");
	cvar_limit_poziomu = CreateConVar("cod_max_level", "200");
	cvar_proporcja_poziomu = CreateConVar("cod_level_ratio", "35");
	cvar_proporcja_punktow = CreateConVar("cod_points_level", "2");
	cvar_limit_inteligencji = CreateConVar("cod_max_intelligence", "100");
	cvar_limit_zdrowia = CreateConVar("cod_max_health", "100");
	cvar_limit_obrazen = CreateConVar("cod_max_damage", "100");
	cvar_limit_wytrzymalosci = CreateConVar("cod_max_stamina", "100");
	cvar_limit_kondycji = CreateConVar("cod_max_trim", "100");
	cvar_wytrzymalosc_itemow = CreateConVar("cod_item_stamina", "10");
	cvar_max_wytrzymalosc_itemow = CreateConVar("cod_item_max_stamina", "100");
}