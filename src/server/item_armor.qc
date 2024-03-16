/*
 * Copyright (c) 2022-2024 Marco Cawthorne <marco@icculus.org>
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

class
TFCArmor:NSRenderableEntity
{
	float m_flRespawnDelay;
	int m_iTeamUses;
	int m_iArmorValue;

	void(void) TFCArmor;

	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(void) Spawned;
	virtual void(string,string) SpawnKey;
};

void
TFCArmor::TFCArmor(void)
{
	m_flRespawnDelay = 0.0f;
	m_iTeamUses = 0i;
	m_iArmorValue = 0i;
}

void
TFCArmor::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "armorvalue":
		m_iArmorValue = ReadInt(setValue);
		break;
	case "team_no":
		m_iTeamUses = ReadInt(setValue);
		break;
	case "respawn_delay":
		m_flRespawnDelay = ReadFloat(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
TFCArmor::Spawned(void)
{
	super::Spawned();
	Sound_Precache("item_armor_tfc.pickup");
}

void
TFCArmor::Respawn(void)
{
	SetModel(GetSpawnModel());
	SetSize([-16,-16,0], [16,16,56]);
	SetSolid(SOLID_TRIGGER);
	SetOrigin(GetSpawnOrigin());
	DropToFloor();
	botinfo = BOTINFO_ARMOR;
}

void
TFCArmor::Touch(entity eToucher)
{
	if (eToucher.classname != "player") {
		return;
	}
	player pl = (player)eToucher;

	/* check for team eligibility */
	if (m_iTeamUses)
	if (pl.team != m_iTeamUses)
		return;

	/* if we can't add anything, don't bother */
	if (pl.armor >= pl.m_iMaxArmor && pl.m_iAmmoCells >= pl.m_iMaxCells)
		return;

	int ap;
	int tp = 0;

	/* get remaining points */
	ap = pl.m_iMaxArmor - pl.armor;
	tp = m_iArmorValue;

	/* if that's all we can give... */
	if (ap > tp) {
		pl.armor += tp;
	} else {
		/* give whatever armor points we need */
		pl.armor += ap;

		/* give the remaining as metal... engineers only!*/
		if (pl.classtype == CLASS_ENGINEER) {
			pl. m_iAmmoCells = bound(0, pl.m_iAmmoCells + (tp - ap), pl.m_iMaxCells);
		}
	}

	Sound_Play(this, CHAN_ITEM, "item_armor_tfc.pickup");

	/* hide and respawn */
	Disappear();
	ScheduleThink(Respawn, m_flRespawnDelay);
}
