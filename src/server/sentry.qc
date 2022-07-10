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

#define TFC_SENTRY_COST 130

class
TFCSentry:NSSurfacePropEntity
{
	NSSurfacePropEntity m_eHead;

	void(void) TFCSentry;

	virtual void(player) Place;
	virtual void(void) FinishPlacing;
};

void
TFCSentry::Place(player pl)
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
TFCSentry::FinishPlacing(void)
{
	/* put the top on that spins */
	m_eHead.SetModel("models/sentry1.mdl");
	m_eHead.SetAngles(GetAngles());
	m_eHead.SetSolid(SOLID_BBOX);
	m_eHead.SetMovetype(MOVETYPE_NONE);
	m_eHead.SetSize([-16,-16,0], [16,16,32]);
	m_eHead.SetOrigin(GetOrigin() + [0,0,20]);

	env_message_single(real_owner, "#Sentry_finish");
	Sound_Play(this, CHAN_BODY, "engineer.turret_set");
}

void
TFCSentry::TFCSentry(void)
{
	m_eHead = spawn(NSSurfacePropEntity);
	SetModel("models/base.mdl");
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-16,-16,0], [16,16,20]);
}

void
CSEv_TFC_BuildSentry_(void)
{
	player pl = (player)self;

	/* only engineers can do this */
	if (pl.classtype != CLASS_ENGINEER)
		return;

	/* it costs */
	if (pl.m_iAmmoCells < TFC_SENTRY_COST) {
		env_message_single(pl, "#Build_nometal");
		return;
	}

	/* can't build in the air */
	if (!(pl.flags & FL_ONGROUND)) {
		env_message_single(pl, "#Build_air");
		return;
	}

	if (TFC_ExistsForPlayer(pl, "TFCSentry")) {
		env_message_single(pl, "#Build_onesentry");
		return;
	}

	pl.m_iAmmoCells -= TFC_SENTRY_COST;

	/* deploy */
	TFCSentry sentry = spawn(TFCSentry);
	sentry.Place(pl);
} 
