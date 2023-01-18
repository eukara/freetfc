/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_TOPFRAME = PLAYER_CUSTOMFIELDSTART,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED5,
	PLAYER_UNUSED6,
	PLAYER_UNUSED7
};

class player:NSClientPlayer
{
	/* class info */
	PREDICTED_INT(classtype)

	/* animation */
	PREDICTED_INT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_INT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	/* ammo 1 */
	PREDICTED_INT(mag_sbs)
	PREDICTED_INT(mag_dbs)
	PREDICTED_INT(mag_rpg)
	PREDICTED_INT(mag_glauncher)

	/* ammo 2 */
	PREDICTED_INT(m_iAmmoRockets)
	PREDICTED_INT(m_iAmmoNails)
	PREDICTED_INT(m_iAmmoCells)
	PREDICTED_INT(m_iAmmoShells)
	PREDICTED_INT(m_iAmmoDetpack)
	PREDICTED_INT(m_iAmmoMedikit)

	/* ammo 3 */
	PREDICTED_INT(mode_tempstate)

	virtual void(void) Physics_Jump;

#ifdef CLIENT
	virtual void(float,float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	int m_iMaxHealth;
	int m_iMaxArmor;

	int m_iMaxShells;
	int m_iMaxNails;
	int m_iMaxRockets;
	int m_iMaxCells;
	int m_iMaxDetpack;
	int m_iMaxMedikit;

	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;

	virtual void(void) SpawnIntoGame;
	virtual void(classtype_e) MakeClass;
#endif
};

#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
void HUD_AmmoNotify_Check(player pl);
void HUD_ItemNotify_Check(player pl);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{
	/* the generic client attributes */
	NSClientPlayer::ReceiveEntity(new, fl);

	/* animation */
	if (fl & PLAYER_TOPFRAME) {
		anim_top = readbyte();
		anim_top_time = readfloat();
		anim_top_delay = readfloat();
	}
	if (fl & PLAYER_BOTTOMFRAME) {
		anim_bottom = readbyte();
		anim_bottom_time = readfloat();
	}

	if (fl & PLAYER_AMMO1) {
		mag_sbs = readbyte();
		mag_dbs = readbyte();
		mag_rpg = readbyte();
		mag_glauncher = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		m_iAmmoRockets = readbyte();
		m_iAmmoNails = readbyte();
		m_iAmmoCells = readbyte();
		m_iAmmoShells = readbyte();
		m_iAmmoDetpack = readbyte();
		m_iAmmoMedikit = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		mode_tempstate = readbyte();
		classtype = readbyte();
	}

	setorigin(this, origin);

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (fl == UPDATE_ALL)
		PredictPreFrame();

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (fl & PLAYER_ITEMS || fl & PLAYER_HEALTH)
		HUD_ItemNotify_Check(this);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	/* the generic client attributes */
	NSClientPlayer::PredictPreFrame();
	SAVE_STATE(classtype);

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(mag_sbs);
	SAVE_STATE(mag_dbs);
	SAVE_STATE(mag_rpg);
	SAVE_STATE(mag_glauncher);

	SAVE_STATE(m_iAmmoRockets);
	SAVE_STATE(m_iAmmoNails);
	SAVE_STATE(m_iAmmoCells);
	SAVE_STATE(m_iAmmoShells);
	SAVE_STATE(m_iAmmoDetpack);
	SAVE_STATE(m_iAmmoMedikit);

	SAVE_STATE(mode_tempstate);
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	/* the generic client attributes */
	NSClientPlayer::PredictPostFrame();
	ROLL_BACK(classtype);

	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);

	ROLL_BACK(mag_sbs);
	ROLL_BACK(mag_dbs);
	ROLL_BACK(mag_rpg);
	ROLL_BACK(mag_glauncher);

	ROLL_BACK(m_iAmmoRockets);
	ROLL_BACK(m_iAmmoNails);
	ROLL_BACK(m_iAmmoCells);
	ROLL_BACK(m_iAmmoShells);
	ROLL_BACK(m_iAmmoDetpack);
	ROLL_BACK(m_iAmmoMedikit);

	ROLL_BACK(mode_tempstate);
}

#else
void
player::EvaluateEntity(void)
{
	/* the generic client attributes */
	NSClientPlayer::EvaluateEntity();

	/* animation */
	if (ATTR_CHANGED(anim_bottom) || ATTR_CHANGED(anim_bottom_time))
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (ATTR_CHANGED(anim_top) || ATTR_CHANGED(anim_top_time) || ATTR_CHANGED(anim_top_delay))
		SendFlags |= PLAYER_TOPFRAME;

	/* ammo 1 type updates */
	if (ATTR_CHANGED(mag_sbs))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(mag_dbs))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(mag_rpg))
		SendFlags |= PLAYER_AMMO1;
	else if (ATTR_CHANGED(mag_glauncher))
		SendFlags |= PLAYER_AMMO1;

	/* ammo 2 type updates */
	if (ATTR_CHANGED(m_iAmmoRockets))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(m_iAmmoNails))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(m_iAmmoCells))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(m_iAmmoShells))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(m_iAmmoDetpack))
		SendFlags |= PLAYER_AMMO2;
	else if (ATTR_CHANGED(m_iAmmoMedikit))
		SendFlags |= PLAYER_AMMO2;

	if (ATTR_CHANGED(mode_tempstate))
		SendFlags |= PLAYER_AMMO3;

	if (ATTR_CHANGED(classtype))
		SendFlags |= PLAYER_AMMO3;

	SAVE_STATE(mag_sbs);
	SAVE_STATE(mag_dbs);
	SAVE_STATE(mag_rpg);
	SAVE_STATE(mag_glauncher);

	SAVE_STATE(m_iAmmoRockets);
	SAVE_STATE(m_iAmmoNails);
	SAVE_STATE(m_iAmmoCells);
	SAVE_STATE(m_iAmmoShells);
	SAVE_STATE(m_iAmmoDetpack);
	SAVE_STATE(m_iAmmoMedikit);

	SAVE_STATE(mode_tempstate);

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);
	SAVE_STATE(classtype);
}

void
player::SpawnIntoGame(void)
{	
	entity spot = world;

	/* spawn into the world */
	switch (team) {
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

	setorigin(this, spot.origin);
	angles = spot.angles;
	fixangle = TRUE;
}

void
player::MakeClass(classtype_e class)
{
	health = self.max_health = 100;
	takedamage = DAMAGE_YES;
	solid = SOLID_SLIDEBOX;
	movetype = MOVETYPE_WALK;
	flags = FL_CLIENT;
	viewzoom = 1.0;

	/* select our class model */
	model = g_teammodels[classtype];
	setmodel(this, model);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	velocity = [0,0,0];
	gravity = __NULL__;

	armor = activeweapon = g_items = 0;
	iBleeds = TRUE;
	forceinfokey(this, "*spec", "0");
	forceinfokey(this, "*team", ftos(team));

	switch (classtype) {
	case CLASS_SCOUT:
		Weapons_AddItem(this, WEAPON_CROWBAR, -1);
		Weapons_AddItem(this, WEAPON_SBS, -1);
		Weapons_AddItem(this, WEAPON_NAILGUN, -1);
		m_iAmmoShells = 17;
		m_iAmmoNails = 100;

		m_iMaxHealth = 75;
		m_iMaxArmor = 50;
		health = m_iMaxHealth;
		armor = 25;

		m_iMaxShells = 50;
		m_iMaxNails = 200;
		m_iMaxCells = 100;
		m_iMaxRockets = 25;
		env_message_single(this, "HELP_SCOUT");
		break;
	case CLASS_SNIPER:
		Weapons_AddItem(this, WEAPON_CROWBAR, -1);
		Weapons_AddItem(this, WEAPON_SNIPER, -1);
		Weapons_AddItem(this, WEAPON_AUTORIFLE, -1);
		Weapons_AddItem(this, WEAPON_NAILGUN, -1);
		m_iAmmoShells = 60; /* sniper rifles use shells */
		m_iAmmoNails = 50;

		m_iMaxHealth = 90;
		m_iMaxArmor = 50;
		health = m_iMaxHealth;
		armor = 0;

		m_iMaxShells = 75;
		m_iMaxNails = 100;
		m_iMaxCells = 50;
		m_iMaxRockets = 25;
		env_message_single(this, "HELP_SNIPER");
		break;
	case CLASS_SOLDIER:
		Weapons_AddItem(this, WEAPON_CROWBAR, -1);
		Weapons_AddItem(this, WEAPON_SBS, -1);
		Weapons_AddItem(this, WEAPON_DBS, -1);
		Weapons_AddItem(this, WEAPON_RPG, -1);
		m_iAmmoShells = 26;
		m_iAmmoRockets = 6;

		m_iMaxHealth = 100;
		m_iMaxArmor = 200;
		health = m_iMaxHealth;
		armor = 100;

		m_iMaxShells = 100;
		m_iMaxNails = 100;
		m_iMaxCells = 50;
		m_iMaxRockets = 50;
		env_message_single(this, "HELP_SOLDIER");
		break;
	case CLASS_DEMO:
		Weapons_AddItem(this, WEAPON_CROWBAR, -1);
		Weapons_AddItem(this, WEAPON_SBS, -1);
		Weapons_AddItem(this, WEAPON_GLAUNCHER, -1);
		Weapons_AddItem(this, WEAPON_PIPEBOMB, -1);
		m_iAmmoShells = 22;
		m_iAmmoRockets = 14;

		m_iMaxHealth = 90;
		m_iMaxArmor = 100;
		health = m_iMaxHealth;
		armor = 50;

		m_iMaxShells = 75;
		m_iMaxNails = 50;
		m_iMaxCells = 50;
		m_iMaxRockets = 50;
		env_message_single(this, "HELP_DEMOMAN");
		break;
	case CLASS_MEDIC:
		Weapons_AddItem(this, WEAPON_MEDKIT, -1);
		Weapons_AddItem(this, WEAPON_SBS, -1);
		Weapons_AddItem(this, WEAPON_DBS, -1);
		Weapons_AddItem(this, WEAPON_SUPERNAIL, -1);
		m_iAmmoShells = 26;
		m_iAmmoNails = 50;

		m_iMaxHealth = 90;
		m_iMaxArmor = 100;
		health = m_iMaxHealth;
		armor = 50;

		m_iMaxShells = 75;
		m_iMaxNails = 150;
		m_iMaxCells = 50;
		m_iMaxRockets = 25;
		env_message_single(this, "HELP_MEDIC");
		break;
	case CLASS_HVYWEAPON:
		Weapons_AddItem(this, WEAPON_CROWBAR, -1);
		Weapons_AddItem(this, WEAPON_SBS, -1);
		Weapons_AddItem(this, WEAPON_DBS, -1);
		Weapons_AddItem(this, WEAPON_ASSCAN, -1);
		m_iAmmoShells = 176; /* all of the heavy's weapons use shells */

		m_iMaxHealth = 100;
		m_iMaxArmor = 250;
		health = m_iMaxHealth;
		armor = 150;

		m_iMaxShells = 200;
		m_iMaxNails = 200;
		m_iMaxCells = 50;
		m_iMaxRockets = 25;
		env_message_single(this, "HELP_HWGUY");
		break;
	case CLASS_PYRO:
		Weapons_AddItem(this, WEAPON_CROWBAR, -1);
		Weapons_AddItem(this, WEAPON_SBS, -1);
		Weapons_AddItem(this, WEAPON_FLAMER, -1);
		Weapons_AddItem(this, WEAPON_INCENDIARY, -1);
		m_iAmmoShells = 12;
		m_iAmmoCells = 120;
		m_iAmmoRockets = 5;

		m_iMaxHealth = 100;
		m_iMaxArmor = 150;
		health = m_iMaxHealth;
		armor = 50;

		m_iMaxShells = 40;
		m_iMaxNails = 50;
		m_iMaxCells = 200;
		m_iMaxRockets = 60;
		env_message_single(this, "HELP_PYRO");
		break;
	case CLASS_SPY:
		Weapons_AddItem(this, WEAPON_KNIFE, -1);
		Weapons_AddItem(this, WEAPON_TRANQUIL, -1);
		Weapons_AddItem(this, WEAPON_DBS, -1);
		Weapons_AddItem(this, WEAPON_NAILGUN, -1);
		m_iAmmoShells = 24; /* tranquil and dbs use shells */
		m_iAmmoNails = 50;

		m_iMaxHealth = 90;
		m_iMaxArmor = 100;
		health = m_iMaxHealth;
		armor = 25;

		m_iMaxShells = 40;
		m_iMaxNails = 50;
		m_iMaxCells = 30;
		m_iMaxRockets = 15;
		env_message_single(this, "HELP_SPY");
		break;
	case CLASS_ENGINEER:
		Weapons_AddItem(this, WEAPON_WRENCH, -1);
		Weapons_AddItem(this, WEAPON_RAILGUN, -1);
		Weapons_AddItem(this, WEAPON_DBS, -1);
		m_iAmmoCells = 100;
		m_iAmmoNails = 25;
		m_iAmmoShells = 4;

		m_iMaxHealth = 80;
		m_iMaxArmor = 50;
		health = m_iMaxHealth;
		armor = 25;

		m_iMaxShells = 50;
		m_iMaxNails = 50;
		m_iMaxCells = 200;
		m_iMaxRockets = 30;
		env_message_single(this, "HELP_ENGINEER");
		break;
	}

	g_items |= ITEM_SUIT;
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, flChanged);

	if (flChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (flChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}

	if (flChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, mag_sbs);
		WriteByte(MSG_ENTITY, mag_dbs);
		WriteByte(MSG_ENTITY, mag_rpg);
		WriteByte(MSG_ENTITY, mag_glauncher);
	}

	if (flChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, m_iAmmoRockets);
		WriteByte(MSG_ENTITY, m_iAmmoNails);
		WriteByte(MSG_ENTITY, m_iAmmoCells);
		WriteByte(MSG_ENTITY, m_iAmmoShells);
		WriteByte(MSG_ENTITY, m_iAmmoDetpack);
		WriteByte(MSG_ENTITY, m_iAmmoMedikit);
	}

	if (flChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, mode_tempstate);
		WriteByte(MSG_ENTITY, classtype);
	}

	return (1);
}
#endif
