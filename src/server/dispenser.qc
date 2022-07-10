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

class
TFCDispenser:NSSurfacePropEntity
{

	void(void) TFCDispenser;

	virtual void(player) Place;
	virtual void(void) FinishPlacing;
};

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
CSEv_TFC_BuildDispenser_(void)
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
