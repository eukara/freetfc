/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

/* A lot of this has been sourced and verified via:
 * http://www.bspquakeeditor.com/archive/planetfortress_com_factory/files/tfortmap.txt
 */

typedef enum
{
	TFGOAL_ACTIVE, /* cannot be touched by a player */
	TFGOAL_INACTIVE, /* will become ACTIVE when the toucher meets the criteria */
	TFGOAL_REMOVED /* cannot be touched by players at all, only other events */
} tfgoal_state;

/* conditions under which the goal will activate */
typedef enumflags
{
	TFACT_NONE,
	TFACT_TOUCH,
	TFACT_DETPACK,
	TFACT_FAILURE,
	TFACT_DROPTOGROUND = 2048
} tfgoal_activation;

typedef enumflags
{
	TFEF_ACTIVATOR, /* single activator */
	TFEF_ACTTEAM, /* activators team */
	TFEF_NONACTTEAM, /* everyone elses but activators team */
	TFEF_NONACTIVATORS, /* everyone but the activator */
	TFEF_WALLOBSTRUCT, /* everyone not tracelineable? */
	TFEF_PVS, /* everyone not in the same pvs? */
	TFEF_CHECK, /* no idea */
} tfgoal_effects;

typedef enumflags
{
	TFRESULT_NONE = 0,
	TFRESULT_REMOVE = 1, /* remove right away */
	TFRESULT_SUBGOAL_MODS = 2,
	TFRESULT_SCORES = 4,
	TFRESULT_SUBGOAL_NOMODS = 8,
	TFRESULT_NODISGUISE = 16,
	TFRESULT_FORCERESPAWN = 32,
	TFRESULT_REMOVE_BUILDINGS = 64
} tfgoal_result;

/* point entity version */
class info_tfgoal:NSRenderableEntity
{
	string m_strName;
	string m_strActivatedSound;

	int m_iGoalID; /* goal identifer */
	int m_iGoalGroupID; /* goal group ID */

	tfgoal_state m_tfgState;
	tfgoal_activation m_tfgActivation;
	tfgoal_effects m_tfgEffects;
	tfgoal_result m_tfgResult;
	player m_Activator;

	float m_dMustCarry; /* player must carry item of this ID */
	float m_dRespawn; /* respawn after num seconds on TFRESULT_REMOVE */ 

	float m_dTeamBlueGain;
	float m_dTeamRedGain;
	float m_dTeamYellowGain;
	float m_dTeamGreenGain;
	float m_dScore; /* score to be added to the activators' team score */
	int m_iTeamUses; /* who can use it */
	int m_iTeamOwner; /* owner of the item */

	int m_iHealth;
	int m_iArmor;
	int m_iShells;
	int m_iNails;
	int m_iCells;
	int m_iMedikit;
	int m_iRockets;
	int m_iDetpack;

	/* visual fluff */
	string m_msgAll; /* global */
	string m_msgActivator; /* AP */
	string m_msgActTeam; /* AP team */
	string m_msgNonActTeam; /* non-AP team */
	string m_msgOwnerTeam; /* owner team */
	string m_msgNonOwnerTeams;  /* non-owner team */

	string m_voxAll; /* global */
	string m_voxActivator; /* AP */
	string m_voxActTeam; /* AP team */
	string m_voxNonActTeam; /* non-AP team */
	string m_voxOwnerTeam; /* owner team */
	string m_voxNonOwnerTeams;  /* non-owner team */

	void(void) info_tfgoal;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
info_tfgoal::Touch(entity eToucher)
{
	item_tfgoal findme = __NULL__;

	if (eToucher.classname != "player") {
		return;
	}
	player pl = (player)eToucher;

	/* check for state */
	if (m_tfgState != TFGOAL_INACTIVE)
		return;

	/* check for team eligibility */
	if (m_iTeamUses)
	if (eToucher.team != m_iTeamUses)
		return;

	/* check for the must-have carry */
	if (m_dMustCarry) {
		/* find the needle in the haystack */
		for (entity e = world; (e = find(e, ::classname, "item_tfgoal"));) {
			item_tfgoal a = (item_tfgoal)e;

			if (a.m_dItemID == m_dMustCarry)
				findme = a;
		}

		if (!findme) {
			print("can't find the pickup\n");
			return;
		}

		if (findme.solid != SOLID_NOT) {
			print("the item is not picked up.\n");
			return;
		}

		if (findme.m_eActivator != pl) {
			print("you are not the items activator.\n");
			return;
		} else {
			/* unset the activator and make it reappear */
			findme.Respawn();
		}

		/* mark as removed on the player end, too. */
		pl.g_items &= ~ITEM_GOALITEM;
		forceinfokey(pl, "*goalitem_t", "");
	}

	sound(this, CHAN_ITEM, m_strActivatedSound, 1.0f, ATTN_NORM);
	Logging_Pickup(eToucher, this, m_strName);

	/* here we increase/decrease funstuff */
	pl.health += m_iHealth;
	pl.armor += m_iArmor;
	pl.m_iAmmoShells += m_iShells;
	pl.m_iAmmoNails += m_iNails;
	pl.m_iAmmoCells += m_iCells;
	pl.m_iAmmoRockets += m_iRockets;
	pl.m_iAmmoMedikit += m_iMedikit;
	pl.m_iAmmoDetpack += m_iDetpack;

	/* clamp */
	pl.health = bound(0, pl.health, pl.m_iMaxHealth);
	pl.armor = bound(0, pl.armor, pl.m_iMaxArmor);
	pl.m_iAmmoShells = bound(0, pl.m_iAmmoShells, pl.m_iMaxShells);
	pl.m_iAmmoNails = bound(0, pl.m_iAmmoNails, pl.m_iMaxNails);
	pl.m_iAmmoCells = bound(0, pl.m_iAmmoCells, pl.m_iMaxCells);
	pl.m_iAmmoRockets = bound(0, pl.m_iAmmoRockets, pl.m_iMaxRockets);

	pl.frags += frags;

	string ts;
	if (m_dScore) {
		ts = sprintf("teamscore_%i", m_iTeamUses);
		forceinfokey(world, ts, sprintf("%d", serverkeyfloat(ts) + m_dScore));
	}
	if (m_dTeamBlueGain) {
		ts = "teamscore_1";
		forceinfokey(world, ts, sprintf("%d", serverkeyfloat(ts) + m_dTeamBlueGain));
	}
	if (m_dTeamRedGain) {
		ts = "teamscore_2";
		forceinfokey(world, ts, sprintf("%d", serverkeyfloat(ts) + m_dTeamRedGain));
	}
	if (m_dTeamYellowGain) {
		ts = "teamscore_3";
		forceinfokey(world, ts, sprintf("%d", serverkeyfloat(ts) + m_dTeamYellowGain));
	}
	if (m_dTeamGreenGain) {
		ts = "teamscore_4";
		forceinfokey(world, ts, sprintf("%d", serverkeyfloat(ts) + m_dTeamGreenGain));
	}

	/* message broadcaster */
	if (m_msgAll) {
		env_message_broadcast(m_msgAll);
	} else {
		for (entity e = world; (e = find(e, ::classname, "player")); ) {
			if (e == pl) {
				env_message_single(e, m_msgActivator);
			} else if (e.team == pl.team ) {
				env_message_single(e, m_msgActTeam);
			} else if (e.team != pl.team) {
				if (e.team == m_iTeamOwner && m_msgOwnerTeam)
					env_message_single(e, m_msgOwnerTeam);
				else {
					if (m_msgNonOwnerTeams)
						env_message_single(e, m_msgNonOwnerTeams);
					else
						env_message_single(e, m_msgNonActTeam);
				}
			}
		}
	}

	/* vox speaker */
	if (m_voxAll) {
		Vox_Sentence_Broadcast(m_voxAll);
	} else {
		for (entity e = world; (e = find(e, ::classname, "player")); ) {
			if (e == pl) {
				Vox_Sentence_Single(e, m_voxActivator);
			} else if (e.team == pl.team ) {
				Vox_Sentence_Single(e, m_voxActTeam);
			} else if (e.team != pl.team) {
				if (e.team == m_iTeamOwner && m_voxOwnerTeam)
					Vox_Sentence_Single(e, m_voxOwnerTeam);
				else {
					if (m_voxNonOwnerTeams)
						Vox_Sentence_Single(e, m_voxNonOwnerTeams);
					else
						Vox_Sentence_Single(e, m_voxNonActTeam);
				}
			}
		}
	}
	
	/* remove? */
	if (m_tfgResult & TFRESULT_REMOVE) {
		Disappear();
		ScheduleThink(Respawn, m_dRespawn);
	}
}

void
info_tfgoal::Respawn(void)
{
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetModel(GetSpawnModel());
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	SetOrigin(GetSpawnOrigin());
}

void
info_tfgoal::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "netname":
		netname = strValue;
		break;
	case "noise":
		m_strActivatedSound = strValue;
		break;
	case "mdl":
		model = strValue;
		break;
	case "goal_state":
		m_tfgState = stof(strValue);
		break;
	case "g_a":
		m_tfgActivation = stof(strValue);
		break;
	case "g_e":
		m_tfgEffects = stof(strValue);
		break;
	case "goal_result":
		m_tfgResult = stof(strValue);
		break;
	case "items_allowed":
		m_dMustCarry = stof(strValue);
		break;
	case "team_no":
		m_iTeamUses = stoi(strValue);
		break;
	case "owned_by":
		m_iTeamOwner = stoi(strValue);
		break;
	case "count":
		m_dScore = stof(strValue);
		break;
	case "wait":
		m_dRespawn = stof(strValue);
		break;
	case "increase_team1":
		m_dTeamBlueGain = stof(strValue);
		break;
	case "increase_team2":
		m_dTeamRedGain = stof(strValue);
		break;
	case "increase_team3":
		m_dTeamYellowGain = stof(strValue);
		break;
	case "increase_team4":
		m_dTeamGreenGain = stof(strValue);
		break;
	/* messages that get sent */
	case "b_b":
		m_msgAll = strValue; /* global */
		break;
	case "message":
		m_msgActivator = strValue; /* AP */
		break;
	case "b_t":
	case "team_broadcast":
		m_msgActTeam = strValue; /* AP team */
		break;
	case "b_n":
	case "netname_non_team_broadcast":
		m_msgNonActTeam = strValue; /* non-AP team */
		break;
	case "b_o":
	case "owners_team_broadcast":
		m_msgOwnerTeam = strValue; /* owner team */
		break;
	case "non_owners_team_broadcast":
		m_msgNonOwnerTeams = strValue;  /* non-owner team */
		break;
	/* sentences that get played */
	case "speak":
		m_voxAll = strValue; /* global */
		break;
	case "AP_speak":
		m_voxActivator = strValue; /* AP */
		break;
	case "team_speak":
		m_voxActTeam = strValue; /* AP team */
		break;
	case "non_team_speak":
		m_voxNonActTeam = strValue; /* non-AP team */
		break;
	case "owners_team_speak":
		m_voxOwnerTeam = strValue; /* owner team */
		break;
	case "non_owners_team_speak":
		m_voxNonOwnerTeams = strValue;  /* non-owner team */
		break;
	/* AP manipulators */
	case "health":
		m_iHealth = stoi(strValue);
		break;
	case "armor":
		m_iArmor = stoi(strValue);
		break;
	case "ammo_shells":
		m_iShells = stoi(strValue);
		break;
	case "ammo_nails":
		m_iNails = stoi(strValue);
		break;
	case "ammo_rockets":
		m_iRockets = stoi(strValue);
		break;
	case "ammo_cells":
		m_iCells = stoi(strValue);
		break;
	case "ammo_medikit":
		m_iMedikit = stoi(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
info_tfgoal::info_tfgoal(void)
{
	m_tfgState = TFGOAL_INACTIVE;
	m_tfgResult = TFRESULT_REMOVE;

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		SpawnKey(argv(i), argv(i+1));
	}

	precache_sound(m_strActivatedSound);

	super::NSRenderableEntity();
	info_tfgoal::Respawn();
}

/* the brush based version of tfgoal */
class i_t_g:info_tfgoal
{
	void(void) i_t_g;
	virtual void(void) Respawn;
};

void
i_t_g::Respawn(void)
{
	SetSolid(SOLID_BSPTRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	Hide();
}

void
i_t_g::i_t_g(void)
{
	classname = "info_tfgoal";

	m_tfgState = TFGOAL_INACTIVE;
	m_tfgResult = TFRESULT_NONE;

	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		SpawnKey(argv(i), argv(i+1));
	}

	super::NSRenderableEntity();

	precache_sound(m_strActivatedSound);
	Respawn();
}
