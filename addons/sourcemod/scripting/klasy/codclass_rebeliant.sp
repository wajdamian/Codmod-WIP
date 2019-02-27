#include <sourcemod>
#include <codmod>

new const String:nazwa[] = "Rebeliant";
new const String:opis[] = "Brak";
new const String:bronie[] = "#weapon_sg556#weapon_glock#weapon_incgrenade";
new const inteligencja = 0;
new const zdrowie = 5;
new const obrazenia = 5;
new const wytrzymalosc = 15;
new const kondycja = -30;
new const flagi = 0;

public Plugin:myinfo =
{
	name = nazwa,
	author = "Zerciu & de duk goos quak m8",
	description = "Cod Klasa",
	version = "1.0",
	url = "http://steamcommunity.com/id/Zerciu https://steamcommunity.com/profiles/76561198145991535/"
};
public OnPluginStart()
{
	cod_register_class(nazwa, opis, bronie, inteligencja, zdrowie, obrazenia, wytrzymalosc, kondycja, flagi);
}