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

/*QUAKED item_armor1 (0 0 0.8) (-16 -16 0) (16 16 56)

TEAM FORTRESS/QUAKE (1996) ENTITY

Armor pickup, which will also replenish metal.
It has a 100 points.

-------- KEYS --------
"targetname"    : Name
"areaname"      : Name of the specified area
"team_no"       : Which team can pick up the armor (0 = all)
"respawn_delay" : Time it takes to respawn after having been picked up
*/

/*QUAKED item_armor2 (0 0 0.8) (-16 -16 0) (16 16 56)

TEAM FORTRESS/QUAKE (1996) ENTITY

Armor pickup, which will also replenish metal
It has a 150 points.

-------- KEYS --------
"targetname"    : Name
"areaname"      : Name of the specified area
"team_no"       : Which team can pick up the armor (0 = all)
"respawn_delay" : Time it takes to respawn after having been picked up
*/

/*QUAKED item_armor3 (0 0 0.8) (-16 -16 0) (16 16 56)

TEAM FORTRESS/QUAKE (1996) ENTITY

Armor pickup, which will also replenish metal
It has a 200 points.

-------- KEYS --------
"targetname"    : Name
"areaname"      : Name of the specified area
"team_no"       : Which team can pick up the armor (0 = all)
"respawn_delay" : Time it takes to respawn after having been picked up
*/

class
item_armor:NSRenderableEntity
{
	float m_flRespawnDelay;
	int m_iTeamUses;

	void(void) item_armor;

	virtual void(entity) Touch;
	virtual void(void) Respawn;
	virtual void(string,string) SpawnKey;
};

void
item_armor::Touch(entity eToucher)
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

	/* get the total points the armor can give */
	switch (classname) {
	case "item_armor1":
		tp = 100;
		break;
	case "item_armor2":
		tp = 150;
		break;
	case "item_armor3":
		tp = 200;
		break;
	default:
		print("^1item_armor: unknown armor type\n");
		return;
	}

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
	Hide();
	think = Respawn;
	nextthink = time + m_flRespawnDelay;
}

void
item_armor::SpawnKey(string strKey, string strValue)
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
item_armor::Respawn(void)
{
	/* get the total points the armor can give */
	switch (classname) {
	case "item_armor1":
		SetModel("models/g_armor.mdl");
		break;
	case "item_armor2":
		SetModel("models/y_armor.mdl");
		break;
	case "item_armor3":
		SetModel("models/r_armor.mdl");
		break;
	default:
		print("^1item_armor: unknown armor type\n");
		Destroy();
		return;
	}

	SetSize([-16,-16,0], [16,16,56]);
	SetSolid(SOLID_TRIGGER);
	SetOrigin(GetSpawnOrigin());
	DropToFloor();
}

void
item_armor::item_armor(void)
{
	Sound_Precache("item_armor_tfc.pickup");
}

void
item_armor1(void)
{
	precache_model("models/g_armor.mdl");
	spawnfunc_item_armor();
	self.classname = "item_armor1";
}

void
item_armor2(void)
{
	precache_model("models/y_armor.mdl");
	spawnfunc_item_armor();
	self.classname = "item_armor2";
}

void
item_armor3(void)
{
	precache_model("models/r_armor.mdl");
	spawnfunc_item_armor();
	self.classname = "item_armor3";
}
