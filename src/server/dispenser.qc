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

#define TFC_DISPENSER_COST 100

/* The unit has 150 health and can hold up to 400 shells, 600 nails, 300 rockets, 400 cells, and 500 armor points. */

class
TFCDispenser:NSSurfacePropEntity
{
	int m_iShells;
	int m_iNails;
	int m_iRockets;
	int m_iCells;
	int m_iArmor;
	
	void(void) TFCDispenser;

	virtual void(player) Place;
	virtual void(void) FinishPlacing;

	virtual void(void) Replenish;
	virtual void(void) ClampValues;
};


void
TFCDispenser::ClampValues(void)
{
	if (m_iShells >= 400)
		m_iShells = 400;

	if (m_iNails >= 600)
		m_iNails = 600;

	if (m_iRockets >= 300)
		m_iRockets = 300;

	if (m_iCells >= 400)
		m_iCells = 400;

	if (m_iArmor >= 500)
		m_iArmor = 500;
}

void
TFCDispenser::Replenish(void)
{
	m_iShells += 5;
	m_iNails += 5;
	m_iRockets += 5;
	m_iCells += 5;
	m_iArmor += 5;
	ClampValues();

	nextthink = time + 1.0f;
}

void
TFCDispenser::Touch(entity eToucher)
{
	if (team != real_owner.team)
		return;

	player pl = (player)eToucher;
}

void
TFCDispenser::Place(player pl)
{
	SetAngles(pl.GetAngles());

	makevectors([0, pl.v_angle[1], 0]);
	SetOrigin(pl.origin + (v_forward * 48));
	DropToFloor();

	think = FinishPlacing;
	nextthink = time + 5.0f;
	real_owner = pl;
	colormap = pl.colormap;

	env_message_single(real_owner, "#Engineer_building");
	Sound_Play(this, CHAN_BODY, "engineer.build");
}

void
TFCDispenser::FinishPlacing(void)
{
	env_message_single(real_owner, "#Dispenser_finish");
	Sound_Play(this, CHAN_BODY, "engineer.turret_set");
}

void
TFCDispenser::TFCDispenser(void)
{
	SetModel("models/dispenser.mdl");
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-16,-16,0], [16,16,48]);
}

void
TFCDispenser_Build(void)
{
	player pl = (player)self;

	/* only engineers can do this */
	if (pl.classtype != CLASS_ENGINEER)
		return;

	/* it costs */
	if (pl.m_iAmmoCells < TFC_DISPENSER_COST) {
		env_message_single(pl, "#Build_nometal");
		return;
	}

	/* can't build in the air */
	if (!(pl.flags & FL_ONGROUND)) {
		env_message_single(pl, "#Build_air");
		return;
	}

	if (TFC_ExistsForPlayer(pl, "TFCDispenser")) {
		env_message_single(pl, "#Build_onedispenser");
		return;
	}

	pl.m_iAmmoCells -= TFC_DISPENSER_COST;

	/* deploy */
	TFCDispenser dispenser = spawn(TFCDispenser);
	dispenser.Place(pl);
}

void
TFCDispenser_Dismantle(void)
{
	
}
