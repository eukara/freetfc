/*
 * Copyright (c) 2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED item_healthkit (0 0 0.8) (-16 -16 -36) (16 16 36)

TEAM FORTRESS CLASSIC (1999) ENTITY

Health pickup. Unlike Team Fortress, this is the only one and it provides
25 health at all times.

-------- KEYS --------
"targetname"    : Name
"areaname"      : Name of the specified area
"team_no"       : Which team can pick up the armor (0 = all)
"respawn_delay" : Time it takes to respawn after having been picked up
*/

class
item_healthkit:NSRenderableEntity
{
	int m_iTeamUses;
	float m_flRespawnDelay;

	void(void) item_healthkit;

	virtual void(void) Respawn;
	virtual void(entity) Touch;
	virtual void(string,string) SpawnKey;
};

void
item_healthkit::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}
	player pl = (player)eToucher;

	/* check for team eligibility */
	if (m_iTeamUses)
	if (pl.team != m_iTeamUses)
		return;

	/* leave when full */
	if (pl.health >= pl.m_iMaxHealth)
		return;

	pl.health = bound(0, pl.health + 25, pl.m_iMaxHealth);

	Sound_Play(this, CHAN_ITEM, "item_healthkit_tfc.pickup");

	/* hide and respawn */
	Disappear();
	ScheduleThink(Respawn, m_flRespawnDelay);
}

void
item_healthkit::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "team_no":
		m_iTeamUses = stoi(strValue);
		break;
	case "respawn_delay":
		m_flRespawnDelay = stof(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
item_healthkit::Respawn(void)
{
	SetModel("models/w_medkit.mdl");
	SetSize([-16,-16,0], [16,16,56]);
	SetSolid(SOLID_TRIGGER);
	SetOrigin(GetSpawnOrigin());
	DropToFloor();
}

void
item_healthkit::item_healthkit(void)
{
	Sound_Precache("item_healthkit_tfc.pickup");
	m_flRespawnDelay = 30.0f;
}