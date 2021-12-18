/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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
	PLAYER_KEEPALIVE,
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ORIGIN_Z,
	PLAYER_ANGLES_X,
	PLAYER_ANGLES_Y,
	PLAYER_COLORMAP,
	PLAYER_VELOCITY,
	PLAYER_VELOCITY_Z,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_ARMOR,
	PLAYER_MOVETYPE,
	PLAYER_VIEWOFS,
	PLAYER_TOPFRAME,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED1,
	PLAYER_UNUSED2
};

class player:base_player
{
	/* animation */
	PREDICTED_INT(anim_top);
	PREDICTED_FLOAT(anim_top_time);
	PREDICTED_FLOAT(anim_top_delay);
	PREDICTED_INT(anim_bottom);
	PREDICTED_FLOAT(anim_bottom_time);

	/* ammo 1 */
	PREDICTED_INT(mag_sbs);
	PREDICTED_INT(mag_dbs);
	PREDICTED_INT(mag_rpg);

	/* ammo 2 */
	PREDICTED_INT(m_iAmmoRockets);
	PREDICTED_INT(m_iAmmoNails);
	PREDICTED_INT(m_iAmmoCells);
	PREDICTED_INT(m_iAmmoShells);
	PREDICTED_INT(m_iAmmoDetpack);
	PREDICTED_INT(m_iAmmoMedikit);

	/* ammo 3 */
	PREDICTED_INT(mode_tempstate);

#ifdef CLIENT
	/* External model */
	entity p_model;
	int p_hand_bone;
	int p_model_bone;
	float lastweapon;

	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
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
	base_player::ReceiveEntity(new, fl);

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

	if (fl & PLAYER_ITEMS || fl & PLAYER_HEALTH || fl & PLAYER_ARMOR)
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
	base_player::PredictPreFrame();

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(mag_sbs);
	SAVE_STATE(mag_dbs);
	SAVE_STATE(mag_rpg);

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
	base_player::PredictPostFrame();

	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);

	ROLL_BACK(mag_sbs);
	ROLL_BACK(mag_dbs);
	ROLL_BACK(mag_rpg);

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
	base_player::EvaluateEntity();

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

	SAVE_STATE(mag_sbs);
	SAVE_STATE(mag_dbs);
	SAVE_STATE(mag_rpg);

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
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	/* remove our entity to other clients if we're dead */
	if (health <= 0 && ePEnt != this) {
		return (0);
	}

	/* target client isn't real, they have no client-side. abandon */
	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	/* other players don't need to know about these attributes */
	if (ePEnt != self) {
		fChanged &= ~PLAYER_ITEMS;
		fChanged &= ~PLAYER_HEALTH;
		fChanged &= ~PLAYER_ARMOR;
		fChanged &= ~PLAYER_VIEWOFS;
		fChanged &= ~PLAYER_AMMO1;
		fChanged &= ~PLAYER_AMMO2;
		fChanged &= ~PLAYER_AMMO3;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, fChanged);

	/* the generic client attributes */
	base_player::SendEntity(ePEnt, fChanged);

	if (fChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (fChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}

	if (fChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, mag_sbs);
		WriteByte(MSG_ENTITY, mag_dbs);
		WriteByte(MSG_ENTITY, mag_rpg);
	}

	if (fChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, m_iAmmoRockets);
		WriteByte(MSG_ENTITY, m_iAmmoNails);
		WriteByte(MSG_ENTITY, m_iAmmoCells);
		WriteByte(MSG_ENTITY, m_iAmmoShells);
		WriteByte(MSG_ENTITY, m_iAmmoDetpack);
		WriteByte(MSG_ENTITY, m_iAmmoMedikit);
	}

	if (fChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, mode_tempstate);
	}

	return (1);
}
#endif
