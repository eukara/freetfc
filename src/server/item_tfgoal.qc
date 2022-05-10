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

class item_tfgoal:NSRenderableEntity
{
	float m_dItemID;

	int m_iTeamUses;
	int m_iTeamOwner;

	string m_strSound;
	player m_eActivator;

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

	void(void) item_tfgoal;
	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
};

void
item_tfgoal::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}

	player pl = (player)eToucher;

	/* team filter */
	if (m_iTeamUses)
		if (m_iTeamUses != pl.team)
			return;

	Hide();
	pl.g_items |= ITEM_GOALITEM;
	m_eActivator = pl;

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
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_NONE;
	SetModel(GetSpawnModel());
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	SetOrigin(GetSpawnOrigin());
	m_eActivator = __NULL__;
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
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
item_tfgoal::item_tfgoal(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		SpawnKey(argv(i), argv(i+1));
	}
	precache_sound(m_strSound);

	super::NSRenderableEntity();
	item_tfgoal::Respawn();
}
