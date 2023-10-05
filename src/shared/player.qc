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

#include "../../../valve/src/shared/skeleton.h"

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

	PREDICTED_FLOAT(m_flIdleScale)
	PREDICTED_FLOAT(m_flHallucination)

	virtual void Physics_Jump(void);
	virtual float Physics_MaxSpeed(void);

	virtual void ProcessInput(void);

	nonvirtual void TFC_CookGren1(void);
	nonvirtual void TFC_CookGren2(void);
	nonvirtual void TFC_ReleaseGren1(void);
	nonvirtual void TFC_ReleaseGren2(void);
	virtual void UpdatePlayerAnimation(float);

#ifdef CLIENT
	virtual void ReceiveEntity(float,float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void UpdateAliveCam(void);
	virtual void UpdatePlayerAttachments(bool);

	float m_flNextHallucination;

#else
	NSTimer gren1;
	NSTimer gren2;

	int m_iMaxHealth;
	int m_iMaxArmor;

	int m_iMaxShells;
	int m_iMaxNails;
	int m_iMaxRockets;
	int m_iMaxCells;
	int m_iMaxDetpack;
	int m_iMaxMedikit;

	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity, float);

	virtual void SpawnIntoGame(void);
	virtual void MakeClass(classtype_e);
	virtual void ServerInputFrame(void);

	nonvirtual void TFC_FragSelf(void);
	nonvirtual void TFC_ThrowSecondary(void);
#endif
};

void Animation_PlayerUpdate(player); 
void Animation_TimerUpdate(player, float); 

void
player::UpdatePlayerAnimation(float timelength)
{
	/* calculate our skeletal progression */
	Animation_PlayerUpdate(this);
	/* advance animation timers */
	Animation_TimerUpdate(this, timelength);
}

#ifdef SERVER

void TFCNade_ThrowCaltrop(player);
void TFCNade_ThrowHandGrenade(player);
void TFCNade_ThrowSecondary(player);
void TFCNade_SelfExplode(player);

void
player::TFC_FragSelf(void)
{
	print("Primary exploded in your hand!\n");
	TFCNade_SelfExplode(this);
}

void
player::TFC_ThrowSecondary(void)
{
	print("Secondary exploded in your hand!\n");
	TFCNade_ThrowSecondary(this);
}
#endif

void
player::TFC_CookGren1(void)
{
	/* we're already cooking it */
	if (gflags & GF_GREN1COOK)
		return;

	if (classtype == CLASS_SCOUT) {
		/* caltrop sound */
#ifdef SERVER
		StartSound("weapons/tink1.wav", CHAN_AUTO, 0, true);
#endif
	} else {
		/* grenade timer sound */
#ifdef SERVER
		StartSound("weapons/timer.wav", CHAN_AUTO, 0, true);
		gren1 = gren1.SetupTimer(this, TFC_FragSelf, 3.75f, false);
		gren1.RunTimer();
#endif
	}

	gflags |= GF_GREN1COOK;
}

void
player::TFC_ReleaseGren1(void)
{
	if (!(gflags & GF_GREN1COOK))
		return;

	if (classtype == CLASS_SCOUT) {
		/* release caltrop */
#ifdef SERVER
		TFCNade_ThrowCaltrop(this);
#endif
	} else {
		/* release the nade! */
#ifdef SERVER
		TFCNade_ThrowHandGrenade(this);
		gren1.StopTimer();
#endif
	}

	gflags &= ~GF_GREN1COOK;
}

void
player::TFC_CookGren2(void)
{
	if (gflags & GF_GREN2COOK)
		return;

	if (classtype == CLASS_SNIPER)
		return;

#ifdef SERVER
	StartSound("weapons/timer.wav", CHAN_AUTO, 0, true);
	gren2 = gren2.SetupTimer(this, TFC_ThrowSecondary, 3.75f, false);
	gren2.RunTimer();
#endif

	gflags |= GF_GREN2COOK;
}

void
player::TFC_ReleaseGren2(void)
{
	if (!(gflags & GF_GREN2COOK))
		return;

#ifdef SERVER
	TFCNade_ThrowSecondary(this);
	gren2.StopTimer();
#endif

	gflags &= ~GF_GREN2COOK;
}

void
player::ProcessInput(void)
{
	super::ProcessInput();

	if (input_buttons & INPUT_BUTTON6)
		TFC_CookGren1();
	else
		TFC_ReleaseGren1();

	if (input_buttons & INPUT_BUTTON7)
		TFC_CookGren2();
	else
		TFC_ReleaseGren2();
}

#ifdef CLIENT

.string oldmodel;
string Weapons_GetPlayermodel(player, int);

void
player::UpdatePlayerAttachments(bool visible)
{
	/* draw the flashlight */
	if (gflags & GF_FLASHLIGHT) {
		vector src;
		vector ang;
		
		if (entnum != player_localentnum) {
			src = origin + view_ofs;
			ang = v_angle;
		} else {
			src = pSeat->m_vecPredictedOrigin + [0,0,-8];
			ang = view_angles;
		}

		makevectors(ang);
		traceline(src, src + (v_forward * 8096), MOVE_NORMAL, this);

		if (serverkeyfloat("*bspversion") == BSPVER_HL) {
			dynamiclight_add(trace_endpos + (v_forward * -2), 128, [1,1,1]);
		} else {
			float p = dynamiclight_add(src, 512, [1,1,1], 0, "textures/flashlight");
			dynamiclight_set(p, LFIELD_ANGLES, ang);
			dynamiclight_set(p, LFIELD_FLAGS, 3);
		}
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = Weapons_GetPlayermodel(this, activeweapon);

	/* we changed weapons, update skeletonindex */
	if (p_model.model != p_model.oldmodel) {
		/* free memory */
		if (p_model.skeletonindex)
			skel_delete(p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(p_model, p_model.oldmodel);
		p_model.model = p_model.oldmodel;
		
		/* set the new skeletonindex */
		p_model.skeletonindex = skel_create(p_model.modelindex);

		/* hack this thing in here FIXME: this should be done when popping in/out of a pvs */
		if (autocvar(cl_himodels, 1, "Use high-quality thisayer models over lower-definition ones"))
			setcustomskin(this, "", "geomset 0 2\n");
		else
			setcustomskin(this, "", "geomset 0 1\n");
	}

	/* follow thisayer at all times */
	setorigin(p_model, origin);
	p_model.angles = angles;
	skel_build(p_model.skeletonindex, p_model, p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the thisayer one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(this, g_pbones[i]);
		float wbone = gettagindex(p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(this, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(p_model, wbone, bpos, v_forward, v_right, v_up);
	}
}

void Weapons_AmmoUpdate(entity);
void HUD_AmmoNotify_Check(player pl);
void HUD_ItemNotify_Check(player pl);
void Camera_RunPosBob(vector angles, __inout vector camera_pos);
void Camera_StrafeRoll(__inout vector camera_angle);
void Shake_Update(NSClientPlayer);

void
player::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();
	Camera_RunPosBob(view_angles, cam_pos);

	g_view.SetCameraOrigin(cam_pos);
	Camera_StrafeRoll(view_angles);

	if (m_flIdleScale > 0.0) {
		float wave = sin(time);
		view_angles[0] -= m_flIdleScale * sin(1 * time) * 0.9;
		view_angles[1] -= m_flIdleScale * sin(2 * time) * 0.9;
		view_angles[2] -= m_flIdleScale * sin(0.5 * time) * 0.3;
	}
	g_view.SetCameraAngle(view_angles);

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(punchangle);
}

/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float flChanged)
{
	/* the generic client attributes */
	super::ReceiveEntity(new, flChanged);

	/* animation */
	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	READENTITY_BYTE(mag_sbs, PLAYER_AMMO1)
	READENTITY_BYTE(mag_dbs, PLAYER_AMMO1)
	READENTITY_BYTE(mag_rpg, PLAYER_AMMO1)
	READENTITY_BYTE(mag_glauncher, PLAYER_AMMO1)

	READENTITY_BYTE(m_iAmmoRockets, PLAYER_AMMO2)
	READENTITY_BYTE(m_iAmmoNails, PLAYER_AMMO2)
	READENTITY_BYTE(m_iAmmoCells, PLAYER_AMMO2)
	READENTITY_BYTE(m_iAmmoShells, PLAYER_AMMO2)
	READENTITY_BYTE(m_iAmmoDetpack, PLAYER_AMMO2)
	READENTITY_BYTE(m_iAmmoMedikit, PLAYER_AMMO2)

	READENTITY_BYTE(mode_tempstate, PLAYER_AMMO3)
	READENTITY_BYTE(classtype, PLAYER_AMMO3)
	READENTITY_FLOAT(m_flIdleScale, PLAYER_AMMO3)
	READENTITY_FLOAT(m_flHallucination, PLAYER_AMMO3)

	setorigin(this, origin);

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (flChanged == UPDATE_ALL)
		PredictPreFrame();

	if (flChanged & PLAYER_AMMO1 || flChanged & PLAYER_AMMO2 || flChanged & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (flChanged & PLAYER_ITEMS || flChanged & PLAYER_HEALTH)
		HUD_ItemNotify_Check(this);

	if (m_flHallucination > 0.0) {
		if (m_flNextHallucination > time)
			return;

		TFCHallucination_Insert(origin, v_angle);
		m_flNextHallucination = time + 0.5f + random();
	}
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

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_bottom_time)

	SAVE_STATE(mag_sbs)
	SAVE_STATE(mag_dbs)
	SAVE_STATE(mag_rpg)
	SAVE_STATE(mag_glauncher)

	SAVE_STATE(m_iAmmoRockets)
	SAVE_STATE(m_iAmmoNails)
	SAVE_STATE(m_iAmmoCells)
	SAVE_STATE(m_iAmmoShells)
	SAVE_STATE(m_iAmmoDetpack)
	SAVE_STATE(m_iAmmoMedikit)

	SAVE_STATE(mode_tempstate)
	SAVE_STATE(classtype)
	SAVE_STATE(m_flIdleScale)
	SAVE_STATE(m_flHallucination)
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

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_bottom_time)

	ROLL_BACK(mag_sbs)
	ROLL_BACK(mag_dbs)
	ROLL_BACK(mag_rpg)
	ROLL_BACK(mag_glauncher)

	ROLL_BACK(m_iAmmoRockets)
	ROLL_BACK(m_iAmmoNails)
	ROLL_BACK(m_iAmmoCells)
	ROLL_BACK(m_iAmmoShells)
	ROLL_BACK(m_iAmmoDetpack)
	ROLL_BACK(m_iAmmoMedikit)

	ROLL_BACK(mode_tempstate)
	ROLL_BACK(classtype)
	ROLL_BACK(m_flIdleScale)
	ROLL_BACK(m_flHallucination)
}

#else
void
player::ServerInputFrame(void)
{
	super::ServerInputFrame();
	gflags &= ~GF_NOBUILDZONE;
	gflags &= ~GF_NOGRENADEZONE;

	m_flIdleScale -= input_timelength;
	m_flHallucination -= input_timelength;

	if (m_flIdleScale <= 0.0)
		m_flIdleScale = 0.0f;
}

void
player::EvaluateEntity(void)
{
	/* the generic client attributes */
	NSClientPlayer::EvaluateEntity();

	/* animation */
	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME)

	EVALUATE_FIELD(mag_sbs, PLAYER_AMMO1)
	EVALUATE_FIELD(mag_dbs, PLAYER_AMMO1)
	EVALUATE_FIELD(mag_rpg, PLAYER_AMMO1)
	EVALUATE_FIELD(mag_glauncher, PLAYER_AMMO1)

	EVALUATE_FIELD(m_iAmmoRockets, PLAYER_AMMO2)
	EVALUATE_FIELD(m_iAmmoNails, PLAYER_AMMO2)
	EVALUATE_FIELD(m_iAmmoCells, PLAYER_AMMO2)
	EVALUATE_FIELD(m_iAmmoShells, PLAYER_AMMO2)
	EVALUATE_FIELD(m_iAmmoDetpack, PLAYER_AMMO2)
	EVALUATE_FIELD(m_iAmmoMedikit, PLAYER_AMMO2)

	EVALUATE_FIELD(mode_tempstate, PLAYER_AMMO3)
	EVALUATE_FIELD(classtype, PLAYER_AMMO3)
	EVALUATE_FIELD(m_flIdleScale, PLAYER_AMMO3)
	EVALUATE_FIELD(m_flHallucination, PLAYER_AMMO3)
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
	model = TFC_GetModelForClasstype(classtype);
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
		m_iMaxArmor = 300;
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

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	SENDENTITY_BYTE(mag_sbs, PLAYER_AMMO1)
	SENDENTITY_BYTE(mag_dbs, PLAYER_AMMO1)
	SENDENTITY_BYTE(mag_rpg, PLAYER_AMMO1)
	SENDENTITY_BYTE(mag_glauncher, PLAYER_AMMO1)

	SENDENTITY_BYTE(m_iAmmoRockets, PLAYER_AMMO2)
	SENDENTITY_BYTE(m_iAmmoNails, PLAYER_AMMO2)
	SENDENTITY_BYTE(m_iAmmoCells, PLAYER_AMMO2)
	SENDENTITY_BYTE(m_iAmmoShells, PLAYER_AMMO2)
	SENDENTITY_BYTE(m_iAmmoDetpack, PLAYER_AMMO2)
	SENDENTITY_BYTE(m_iAmmoMedikit, PLAYER_AMMO2)

	SENDENTITY_BYTE(mode_tempstate, PLAYER_AMMO3)
	SENDENTITY_BYTE(classtype, PLAYER_AMMO3)
	SENDENTITY_FLOAT(m_flIdleScale, PLAYER_AMMO3)
	SENDENTITY_FLOAT(m_flHallucination, PLAYER_AMMO3)

	return (1);
}
#endif
