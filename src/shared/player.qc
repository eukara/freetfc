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

class TFPlayer:HLPlayer
{

	void TFPlayer(void);

	/* class info */
	PREDICTED_INT(classtype)

	/* animation */
	PREDICTED_INT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_INT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	PREDICTED_FLOAT(m_flIdleScale)
	PREDICTED_FLOAT(m_flHallucination)

	virtual bool CanSprint(void);
	virtual bool CanCrouch(void);
	virtual bool CanProne(void);
	virtual bool CanLean(void);

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
	virtual void ClientInputFrame(void);

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

void
TFPlayer::TFPlayer(void)
{
	classname = "player";
}

void
TFPlayer::UpdatePlayerAnimation(float timelength)
{
	/* calculate our skeletal progression */
	Animation_PlayerUpdate(this);
	/* advance animation timers */
	Animation_TimerUpdate(this, timelength);
}

/* we invalidate the next two so we can use their input_ bits, INPUT_SPRINT & PRONE */
bool
TFPlayer::CanSprint(void)
{
	return false;
}
bool
TFPlayer::CanProne(void)
{
	return false;
}

bool
TFPlayer::CanCrouch(void)
{
	return true;
}

bool
TFPlayer::CanLean(void)
{
	return false;
}

#ifdef SERVER

void TFCNade_ThrowCaltrop(TFPlayer);
void TFCNade_ThrowHandGrenade(TFPlayer);
void TFCNade_ThrowSecondary(TFPlayer);
void TFCNade_SelfExplode(TFPlayer);

void
TFPlayer::TFC_FragSelf(void)
{
	print("Primary exploded in your hand!\n");
	TFCNade_SelfExplode(this);
}

void
TFPlayer::TFC_ThrowSecondary(void)
{
	print("Secondary exploded in your hand!\n");
	TFCNade_ThrowSecondary(this);
}
#endif

void
TFPlayer::TFC_CookGren1(void)
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
TFPlayer::TFC_ReleaseGren1(void)
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
TFPlayer::TFC_CookGren2(void)
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
TFPlayer::TFC_ReleaseGren2(void)
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
TFPlayer::ProcessInput(void)
{
	super::ProcessInput();

	if (input_buttons & INPUT_SPRINT)
		TFC_CookGren1();
	else
		TFC_ReleaseGren1();

	if (input_buttons & INPUT_PRONE)
		TFC_CookGren2();
	else
		TFC_ReleaseGren2();
}

#ifdef CLIENT

void
TFPlayer::UpdateAliveCam(void)
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

void
TFPlayer::ClientInputFrame(void)
{
	super::ClientInputFrame();

	/* we need to make sure those aren't actually handled by the server */
	if (pSeatTFC->m_bInputGren1 == true) {
		input_buttons |= INPUT_PRONE;
	}
	if (pSeatTFC->m_bInputGren2 == true) {
		input_buttons |= INPUT_SPRINT;
	}
}

/*
=================
player::ReceiveEntity
=================
*/
void
TFPlayer::ReceiveEntity(float new, float flChanged)
{
	/* the generic client attributes */
	NSClientPlayer::ReceiveEntity(new, flChanged);

	/* animation */
	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	READENTITY_BYTE(classtype, PLAYER_AMMOTYPES)
	READENTITY_FLOAT(m_flIdleScale, PLAYER_AMMOTYPES)
	READENTITY_FLOAT(m_flHallucination, PLAYER_AMMOTYPES)

	setorigin(this, origin);

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (flChanged == UPDATE_ALL)
		PredictPreFrame();

	if (flChanged & PLAYER_AMMOTYPES) {
		//Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (flChanged & PLAYER_ITEMS || flChanged & PLAYER_HEALTH) {
		HUD_ItemNotify_Check(this);
	}

	if (m_flHallucination > 0.0) {
		if (m_flNextHallucination > time) {
			return;
		}

		TFCHallucination_Insert(origin, v_angle);
		m_flNextHallucination = time + 0.25f + random(0.25,0.75);
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
TFPlayer::PredictPreFrame(void)
{
	/* the generic client attributes */
	NSClientPlayer::PredictPreFrame();

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_bottom_time)
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
TFPlayer::PredictPostFrame(void)
{
	/* the generic client attributes */
	NSClientPlayer::PredictPostFrame();

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_bottom_time)
	ROLL_BACK(classtype)
	ROLL_BACK(m_flIdleScale)
	ROLL_BACK(m_flHallucination)
}

#else
void
TFPlayer::ServerInputFrame(void)
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
TFPlayer::EvaluateEntity(void)
{
	/* the generic client attributes */
	NSClientPlayer::EvaluateEntity();

	/* animation */
	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME)

	EVALUATE_FIELD(classtype, PLAYER_AMMOTYPES)
	EVALUATE_FIELD(m_flIdleScale, PLAYER_AMMOTYPES)
	EVALUATE_FIELD(m_flHallucination, PLAYER_AMMOTYPES)
}

void
TFPlayer::SpawnIntoGame(void)
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
TFPlayer::MakeClass(classtype_e class)
{
	int atShells = ammoNumForName("ammo_shells");
	int atNails = ammoNumForName("ammo_nails");
	int atCells = ammoNumForName("ammo_cells");
	int atRockets = ammoNumForName("ammo_rockets");
	MakePlayer();

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
		GiveItem("tf_weapon_axe");
		GiveItem("tf_weapon_shotgun");
		GiveItem("tf_weapon_ng");
		GiveAmmo(atShells, 17i);
		GiveAmmo(atNails, 100i);

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
		GiveItem("tf_weapon_axe");
		GiveItem("tf_weapon_sniperrifle");
		GiveItem("tf_weapon_autorifle");
		GiveItem("tf_weapon_ng");
		GiveAmmo(atShells, 60i); /* sniper rifles use shells */
		GiveAmmo(atNails, 50i);

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
		GiveItem("tf_weapon_axe");
		GiveItem("tf_weapon_supershotgun");
		GiveItem("tf_weapon_shotgun");
		GiveItem("tf_weapon_rpg");
		GiveAmmo(atShells, 26i);
		GiveAmmo(atRockets, 6i);

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
		GiveItem("tf_weapon_axe");
		GiveItem("tf_weapon_supershotgun");
		GiveItem("tf_weapon_gl");
		GiveItem("tf_weapon_pl");
		GiveAmmo(atShells, 22i);
		GiveAmmo(atRockets, 14i);

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
		GiveItem("tf_weapon_medikit");
		GiveItem("tf_weapon_supershotgun");
		GiveItem("tf_weapon_shotgun");
		GiveItem("tf_weapon_superng");
		GiveAmmo(atShells, 26i);
		GiveAmmo(atNails, 50i);

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
		GiveItem("tf_weapon_axe");
		GiveItem("tf_weapon_supershotgun");
		GiveItem("tf_weapon_shotgun");
		GiveItem("tf_weapon_ac");
		GiveAmmo(atShells, 176i); /* all of the heavy's weapons use shells */

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
		GiveItem("tf_weapon_axe");
		GiveItem("tf_weapon_supershotgun");
		GiveItem("tf_weapon_flamethrower");
		GiveItem("tf_weapon_ic");
		GiveAmmo(atShells, 12i);
		GiveAmmo(atCells, 120i);
		GiveAmmo(atRockets, 5i);

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
		GiveItem("tf_weapon_knife");
		GiveItem("tf_weapon_tranq");
		GiveItem("tf_weapon_shotgun");
		GiveItem("tf_weapon_ng");
		GiveAmmo(atShells, 24i); /* tranquil and dbs use shells */
		GiveAmmo(atNails, 50i);

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
		GiveItem("tf_weapon_spanner");
		GiveItem("tf_weapon_railgun");
		GiveItem("tf_weapon_shotgun");
		GiveAmmo(atCells, 100i);
		GiveAmmo(atNails, 25i);
		GiveAmmo(atShells, 4i);

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

	GiveItem("item_suit");
}

/*
=================
player::SendEntity
=================
*/
float
TFPlayer::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, flChanged);

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	SENDENTITY_BYTE(classtype, PLAYER_AMMOTYPES)
	SENDENTITY_FLOAT(m_flIdleScale, PLAYER_AMMOTYPES)
	SENDENTITY_FLOAT(m_flHallucination, PLAYER_AMMOTYPES)

	return (1);
}
#endif
