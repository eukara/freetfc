/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

enum
{
	CLASS_SCOUT = 1,
	CLASS_SNIPER,
	CLASS_SOLDIER,
	CLASS_DEMO,
	CLASS_MEDIC,
	CLASS_HVYWEAPON,
	CLASS_PYRO,
	CLASS_SPY,
	CLASS_ENGINEER
};

string g_teammodels[] = {
	"",
	"models/player/scout/scout2.mdl",
	"models/player/sniper/sniper2.mdl",
	"models/player/soldier/soldier2.mdl",
	"models/player/demo/demo.mdl",
	"models/player/medic/medic2.mdl",
	"models/player/hvyweapon/hvyweapon2.mdl",
	"models/player/pyro/pyro2.mdl",
	"models/player/spy/spy2.mdl",
	"models/player/engineer/engineer2.mdl"
};

void
CSEv_TeamJoin_f(float f)
{
	if (self.classname != "player") {
		spawnfunc_player();
	}
	player pl = (player)self;

	entity spot = world;
	pl.classname = "player";
	pl.health = self.max_health = 100;

	pl.takedamage = DAMAGE_YES;
	pl.solid = SOLID_SLIDEBOX;
	pl.movetype = MOVETYPE_WALK;
	pl.flags = FL_CLIENT;
	pl.viewzoom = 1.0;

	/* mess, do it better */
	if (f < 10) {
		pl.team = 1; /* Blue */
		forceinfokey(pl, "topcolor", "0x9aff");
		forceinfokey(pl, "bottomcolor", "0x9aff");
	} else if (f < 20) {
		pl.team = 2; /* Red */
		f -= 10;
		forceinfokey(pl, "topcolor", "0xff1800");
		forceinfokey(pl, "bottomcolor", "0xff1800");
	} else if (f < 30) {
		pl.team = 3; /* Yellow */
		f -= 20;
		forceinfokey(pl, "topcolor", "0xffca00");
		forceinfokey(pl, "bottomcolor", "0xffca00");
	} else if (f < 40) {
		pl.team = 4; /* Green */
		f -= 30;
		forceinfokey(pl, "topcolor", "0x3bff00");
		forceinfokey(pl, "bottomcolor", "0x3bff00");
	}

	forceinfokey(pl, "*team", ftos(pl.team));
	pl.model = g_teammodels[f];
	setmodel(pl, pl.model);
	setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	pl.velocity = [0,0,0];
	pl.gravity = __NULL__;
	pl.frame = 1;
//	pl.SendEntity = Player_SendEntity;
	pl.SendFlags = UPDATE_ALL;
	pl.armor = pl.activeweapon = pl.g_items = 0;

	pl.customphysics = Empty;
	pl.iBleeds = TRUE;
	forceinfokey(pl, "*spec", "0");
	forceinfokey(self, "*deaths", ftos(self.deaths));

	switch (pl.team) {
	case 1:
		spot = Spawn_SelectRandom("info_teamspawn_blue");
		break;
	case 2:
		spot = Spawn_SelectRandom("info_teamspawn_red");
		break;
	case 3:
		spot = Spawn_SelectRandom("info_teamspawn_yellow");
		break;
	case 4:
		spot = Spawn_SelectRandom("info_teamspawn_green");
		break;
	}

	setorigin(pl, spot.origin);
	pl.angles = spot.angles;
	pl.fixangle = TRUE;
	
	switch (f) {
	case CLASS_SCOUT:
		Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
		Weapons_AddItem(pl, WEAPON_SBS, -1);
		Weapons_AddItem(pl, WEAPON_NAILGUN, -1);
		pl.m_iAmmoShells = 17;
		pl.m_iAmmoNails = 100;

		pl.m_iMaxHealth = 75;
		pl.m_iMaxArmor = 50;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 25;

		pl.m_iMaxShells = 50;
		pl.m_iMaxNails = 200;
		pl.m_iMaxCells = 100;
		pl.m_iMaxRockets = 25;
		env_message_single(pl, "HELP_SCOUT");
		break;
	case CLASS_SNIPER:
		Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
		Weapons_AddItem(pl, WEAPON_SNIPER, -1);
		Weapons_AddItem(pl, WEAPON_AUTORIFLE, -1);
		Weapons_AddItem(pl, WEAPON_NAILGUN, -1);
		pl.m_iAmmoShells = 60; /* sniper rifles use shells */
		pl.m_iAmmoNails = 50;

		pl.m_iMaxHealth = 90;
		pl.m_iMaxArmor = 50;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 0;

		pl.m_iMaxShells = 75;
		pl.m_iMaxNails = 100;
		pl.m_iMaxCells = 50;
		pl.m_iMaxRockets = 25;
		env_message_single(pl, "HELP_SNIPER");
		break;
	case CLASS_SOLDIER:
		Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
		Weapons_AddItem(pl, WEAPON_SBS, -1);
		Weapons_AddItem(pl, WEAPON_DBS, -1);
		Weapons_AddItem(pl, WEAPON_RPG, -1);
		pl.m_iAmmoShells = 26;
		pl.m_iAmmoRockets = 6;

		pl.m_iMaxHealth = 100;
		pl.m_iMaxArmor = 200;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 100;

		pl.m_iMaxShells = 100;
		pl.m_iMaxNails = 100;
		pl.m_iMaxCells = 50;
		pl.m_iMaxRockets = 50;
		env_message_single(pl, "HELP_SOLDIER");
		break;
	case CLASS_DEMO:
		Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
		Weapons_AddItem(pl, WEAPON_SBS, -1);
		Weapons_AddItem(pl, WEAPON_GLAUNCHER, -1);
		Weapons_AddItem(pl, WEAPON_PIPEBOMB, -1);
		pl.m_iAmmoShells = 22;
		pl.m_iAmmoRockets = 14;

		pl.m_iMaxHealth = 90;
		pl.m_iMaxArmor = 100;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 50;

		pl.m_iMaxShells = 75;
		pl.m_iMaxNails = 50;
		pl.m_iMaxCells = 50;
		pl.m_iMaxRockets = 50;
		env_message_single(pl, "HELP_DEMOMAN");
		break;
	case CLASS_MEDIC:
		Weapons_AddItem(pl, WEAPON_MEDKIT, -1);
		Weapons_AddItem(pl, WEAPON_SBS, -1);
		Weapons_AddItem(pl, WEAPON_DBS, -1);
		Weapons_AddItem(pl, WEAPON_SUPERNAIL, -1);
		pl.m_iAmmoShells = 26;
		pl.m_iAmmoNails = 50;

		pl.m_iMaxHealth = 90;
		pl.m_iMaxArmor = 100;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 50;

		pl.m_iMaxShells = 75;
		pl.m_iMaxNails = 150;
		pl.m_iMaxCells = 50;
		pl.m_iMaxRockets = 25;
		env_message_single(pl, "HELP_MEDIC");
		break;
	case CLASS_HVYWEAPON:
		Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
		Weapons_AddItem(pl, WEAPON_SBS, -1);
		Weapons_AddItem(pl, WEAPON_DBS, -1);
		Weapons_AddItem(pl, WEAPON_ASSCAN, -1);
		pl.m_iAmmoShells = 176; /* all of the heavy's weapons use shells */

		pl.m_iMaxHealth = 100;
		pl.m_iMaxArmor = 250;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 150;

		pl.m_iMaxShells = 200;
		pl.m_iMaxNails = 200;
		pl.m_iMaxCells = 50;
		pl.m_iMaxRockets = 25;
		env_message_single(pl, "HELP_HWGUY");
		break;
	case CLASS_PYRO:
		Weapons_AddItem(pl, WEAPON_CROWBAR, -1);
		Weapons_AddItem(pl, WEAPON_SBS, -1);
		Weapons_AddItem(pl, WEAPON_FLAMER, -1);
		Weapons_AddItem(pl, WEAPON_INCENDIARY, -1);
		pl.m_iAmmoShells = 12;
		pl.m_iAmmoCells = 120;
		pl.m_iAmmoRockets = 5;

		pl.m_iMaxHealth = 100;
		pl.m_iMaxArmor = 150;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 50;

		pl.m_iMaxShells = 40;
		pl.m_iMaxNails = 50;
		pl.m_iMaxCells = 200;
		pl.m_iMaxRockets = 60;
		env_message_single(pl, "HELP_PYRO");
		break;
	case CLASS_SPY:
		Weapons_AddItem(pl, WEAPON_KNIFE, -1);
		Weapons_AddItem(pl, WEAPON_TRANQUIL, -1);
		Weapons_AddItem(pl, WEAPON_DBS, -1);
		Weapons_AddItem(pl, WEAPON_NAILGUN, -1);
		pl.m_iAmmoShells = 24; /* tranquil and dbs use shells */
		pl.m_iAmmoNails = 50;

		pl.m_iMaxHealth = 90;
		pl.m_iMaxArmor = 100;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 25;

		pl.m_iMaxShells = 40;
		pl.m_iMaxNails = 50;
		pl.m_iMaxCells = 30;
		pl.m_iMaxRockets = 15;
		env_message_single(pl, "HELP_SPY");
		break;
	case CLASS_ENGINEER:
		Weapons_AddItem(pl, WEAPON_WRENCH, -1);
		Weapons_AddItem(pl, WEAPON_RAILGUN, -1);
		Weapons_AddItem(pl, WEAPON_DBS, -1);
		pl.m_iAmmoCells = 100;
		pl.m_iAmmoNails = 25;
		pl.m_iAmmoShells = 4;

		pl.m_iMaxHealth = 80;
		pl.m_iMaxArmor = 50;
		pl.health = pl.m_iMaxHealth;
		pl.armor = 25;

		pl.m_iMaxShells = 50;
		pl.m_iMaxNails = 50;
		pl.m_iMaxCells = 200;
		pl.m_iMaxRockets = 30;
		env_message_single(pl, "HELP_ENGINEER");
		break;
	}

	pl.g_items |= ITEM_SUIT;
} 
