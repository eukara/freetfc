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

class item_tfgoal:CBaseTrigger
{
	float m_dItemID;

	int m_iTeamUses;
	string m_strSound;
	string m_voxTeam;
	string m_voxOtherTeam;
	string m_voxActivator;
	player m_eActivator;

	void(void) item_tfgoal;
	virtual void(void) touch;
	virtual void(void) Respawn;
};

void
item_tfgoal::touch(void)
{
	if (other.classname != "player") {
		return;
	}

	player pl = (player)other;

	/* team filter */
	if (m_iTeamUses)
		if (m_iTeamUses != pl.team)
			return;

	Hide();
	pl.g_items |= ITEM_GOALITEM;
	m_eActivator = pl;

	sound(this, CHAN_ITEM, m_strSound, 1.0f, ATTN_NONE);
	
	/* broadcast via VOX that this was taken from us */
	for (entity e = world; (e = find(e, ::classname, "player")); ) {
		WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte(MSG_MULTICAST, EV_CHAT_VOX);

		if (e.team != m_iTeamUses) {
			WriteString(MSG_MULTICAST, m_voxOtherTeam);
		} else {
			if (e == pl)
				WriteString(MSG_MULTICAST, m_voxActivator);
			else
				WriteString(MSG_MULTICAST, m_voxTeam);
		}

		msg_entity = e;
		multicast([0,0,0], MULTICAST_ONE);
	}
}

void
item_tfgoal::Respawn(void)
{
	solid = SOLID_TRIGGER;
	movetype = MOVETYPE_NONE;
	SetModel(m_oldModel);
	setsize(this, VEC_HULL_MIN, VEC_HULL_MAX);
	SetOrigin(m_oldOrigin);
	m_eActivator = __NULL__;
}

void
item_tfgoal::item_tfgoal(void)
{
	for (int i = 1; i < (tokenize(__fullspawndata) - 1); i += 2) {
		switch (argv(i)) {
		case "noise":
			m_strSound = argv(i+1);
			break;
		case "mdl":
			model = argv(i+1);
			break;
		case "goal_no":
			m_dItemID = stof(argv(i+1));
			break;
		case "team_no":
			m_iTeamUses = stoi(argv(i+1));
			break;
		case "AP_speak":
			m_voxActivator = argv(i+1);
			break;
		case "team_speak":
			m_voxTeam = argv(i+1);
			break;
		case "non_team_speak":
			m_voxOtherTeam = argv(i+1);
			break;
		default:
			break;
		}
	}
	precache_sound(m_strSound);

	CBaseEntity::CBaseEntity();
	item_tfgoal::Respawn();
}
