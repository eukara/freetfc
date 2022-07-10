/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED item_tfgoal (0 0 0.8) (-16 -16 -36) (16 16 36)

TEAM FORTRESS (1996) ENTITY

A gameplay pickup. It generally gets picked up and held.

-------- KEYS --------
"targetname" : Name
"noise"      : Sound sample to play when picked up
"mdl"        : Model the pickup should use
"goal_no"    : Identifer for this pickup, should be unique per map
"team_no"    : Which team can use this item (0 means all)
"owned_by"   : Which team owns this item (aka who can return it)
"pausetime"  : How long the item will stay on ground for when dropped
"b_b"        : Message to show to all when picked up
"message"    : Message to show to the activator when picked up
"b_t"        : Message to show to activator's team when picked up
"b_n"        : Message to show to non-activator's team when picked up
"b_o"        : Message to show to owner team when picked up
"non_owners_team_broadcast" : Message to show to everyone else?

"noise3"     : Message to the owner team when the item is returned
"noise4"     : Message to the other team when the item is returned

"speak"                : VOX announcement to everyone when picked up
"AP_speak"             : VOX announcement to activator when picked up
"team_speak"           : VOX announcement to activator's team when picked up
"non_team_speak"       : VOX announcement to non-activator's team when picked up
"owners_team_speak"    : VOX announcement to owner team when picked up
"non_owners_team_speak": VOX announcement to everyone else

Duplicate keys:
"team_broadcast" : Same as b_t
"netname_non_team_broadcast" : Same as b_n
"owners_team_broadcast" : Same as b_o

*/

typedef enum
{
	GISTATUS_HOME,
	GISTATUS_DROPPED
} goalitem_status_e;

class item_tfgoal:NSRenderableEntity
{
	float m_dItemID;

	int m_iTeamUses;
	int m_iTeamOwner;

	string m_strSound;
	player m_eActivator;

	goalitem_status_e m_status;

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

	string m_returnTeam;
	string m_returnOwner;

	float m_flPausetime;

	void(void) item_tfgoal;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	virtual void(NSClientPlayer) DropReturnable;
	virtual void(void) TeamOwnerReturns;
	virtual void(void) Spawned;
};

void
item_tfgoal::DropReturnable(NSClientPlayer pp)
{
	player pl = (player)pp;

	/* make it available again, put it exactly where we died */
	Respawn();
	SetOrigin(pl.origin);

	/* untag it from the player */
	pl.g_items &= ~ITEM_GOALITEM;

	/* return after N secs */
	think = TeamOwnerReturns;
	nextthink = time + m_flPausetime;
}

void
item_tfgoal::TeamOwnerReturns(void)
{
	Respawn();

	for (entity e = world; (e = find(e, ::classname, "player")); ) {
		if (e.team == m_iTeamUses)
			env_message_single(e, m_returnTeam);
		else if (e.team == m_iTeamOwner)
			env_message_single(e, m_returnOwner);
	}
}

void
item_tfgoal::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}

	player pl = (player)eToucher;

	/* if it's dropped, just let the other team return it...
      otherwise let the other teams pick it up as normal */
	if (m_status == GISTATUS_DROPPED) {
		if (m_iTeamOwner == pl.team) {
			TeamOwnerReturns();
			return;
		}
	}

	/* team filter */
	if (m_iTeamUses)
		if (m_iTeamUses != pl.team)
			return;

	Hide();
	pl.g_items |= ITEM_GOALITEM;
	m_eActivator = pl;
	think = __NULL__;
	nextthink = 0.0f;

	sound(this, CHAN_ITEM, m_strSound, 1.0f, ATTN_NONE);

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
}

void
item_tfgoal::Respawn(void)
{
	SetModel(GetSpawnModel());
	SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	SetSolid(SOLID_TRIGGER);
	SetOrigin(GetSpawnOrigin());
	m_eActivator = __NULL__;
	think = __NULL__;
	nextthink = 0.0f;
}

void
item_tfgoal::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "noise":
		m_strSound = strValue;
		break;
	case "mdl":
		model = strValue;
		break;
	case "goal_no":
		m_dItemID = stof(strValue);
		break;
	case "team_no":
		m_iTeamUses = stoi(strValue);
		break;
	case "owned_by":
		m_iTeamOwner = stoi(strValue);
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
	case "noise4":
		m_returnTeam = strValue;
		break;
	case "noise3":
		m_returnOwner = strValue;
		break;
	case "pausetime":
		m_flPausetime = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
item_tfgoal::Spawned(void)
{
	super::Spawned();	
	precache_sound(m_strSound);
}

void
item_tfgoal::item_tfgoal(void)
{
	m_status = GISTATUS_HOME;
	m_returnOwner = m_returnTeam = __NULL__;
	m_flPausetime = 0;
}
