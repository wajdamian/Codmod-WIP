#if defined _codmod_included
  #endinput
#endif
#define _codmod_included

#define COD_CONTINUE 0
#define COD_STOP 4

native cod_set_user_bonus_weapons(client, const String:nazwa[]);
native cod_get_user_bonus_weapons(client, const String:nazwa[], const MaxLeng);

native cod_set_user_bonus_intelligence(client, wartosc);
native cod_set_user_bonus_health(client, wartosc);
native cod_set_user_bonus_damage(client, wartosc);
native cod_set_user_bonus_stamina(client, wartosc);
native cod_set_user_bonus_trim(client, wartosc);

native cod_get_user_intelligence(client, inteligencja_zdobyta, inteligencja_bonusowa, inteligencja_klasy);
native cod_get_user_health(client, zdrowie_zdobyte, zdrowie_bonusowe, zdrowie_klasy);
native cod_get_user_damage(client, obrazenia_zdobyte, obrazenia_bonusowe, obrazenia_klasy);
native cod_get_user_stamina(client, wytrzymalosc_zdobyta, wytrzymalosc_bonusowa, wytrzymalosc_klasy);
native cod_get_user_trim(client, kondycja_zdobyta, kondycja_bonusowa, kondycja_klasy);
native cod_get_user_points(client);

native cod_get_user_maks_intelligence(client);
native cod_get_user_maks_health(client);
native cod_get_user_maks_damage(client, const String:obrazenia[], const MaxLeng);
native cod_get_user_maks_stamina(client, const String:wytrzymalosc[], const MaxLeng);
native cod_get_user_maks_trim(client, const String:kondycja[], const MaxLeng);

native cod_set_user_xp(client, wartosc);
native cod_add_user_xp(client, wartosc);
native cod_set_user_class(client, klasa, zmiana);
native cod_set_user_item(client, item, wartosc, wytrzymalosc);
native cod_set_user_item_stamina(client, wartosc);

native cod_get_user_xp(client);
native cod_get_level_xp(poziom);
native cod_get_user_level(client);
native cod_get_user_level_all(client);
native cod_get_user_class(client);
native cod_get_user_item(client);
native cod_get_user_item_skill(client);
native cod_get_user_item_stamina(client);

native cod_get_classes_num();
native cod_get_classid(const String:nazwa[]);
native cod_get_class_name(klasa, const String:nazwa[], const MaxLeng);
native cod_get_class_desc(klasa, const String:opis[], const MaxLeng);
native cod_get_class_weapon(klasa, const String:bronie[], const MaxLeng);
native cod_get_class_intelligence(klasa);
native cod_get_class_health(klasa);
native cod_get_class_damage(klasa);
native cod_get_class_stamina(klasa);
native cod_get_class_trim(klasa);
native cod_get_class_flags(klasa);

native cod_get_items_num();
native cod_get_itemid(const String:nazwa[]);
native cod_get_item_name(item, const String:nazwa[], const MaxLeng);
native cod_get_item_desc(item, const String:nazwa[], const MaxLeng);

native cod_inflict_damage(client, attacker, damage);
native cod_register_class(const String:nazwa[], const String:opis[], const String:bronie[], inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
native cod_register_item(const String:nazwa[], const String:opis[], min_wartosc, max_wartosc);
native cod_perform_blind(int client, int msecs, int red, int greeg, int blue, int alpha)

forward cod_class_enabled(client, klasa);
forward cod_class_disabled(client, klasa);
forward cod_class_skill_used(client, klasa);

forward cod_item_enabled(client, wartosc, item);
forward cod_item_disabled(client, item);
forward cod_item_used(client, item);

forward cod_on_give_exp(client, float &multiplier);
forward Action cod_on_player_blind(int client, int &mSecs);

public bool:IsValidClient(client)
{
	if(client >= 1 && client <= MaxClients && IsClientInGame(client))
		return true;

	return false;
}