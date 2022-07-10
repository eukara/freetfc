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

#define TFC_TELEPORTER_COST 125

/* main teleporter */
class
TFCTeleporter:NSSurfacePropEntity
{
	float m_flNextTeleport;

	void(void) TFCTeleporter;

	virtual void(player) Place;
	virtual void(void) FinishPlacing;
	virtual void(entity) Touch;
};

void
TFCTeleporter::Touch(entity eToucher)
{
	if (eToucher.team != real_owner.team)
		return;

	if (m_flNextTeleport > time)
		return;

	TFCTeleporter target = world;
	string exitname;

	if (classname == "TFCTeleporter") 
		exitname = "TFCTeleporterExit";
	else
		return;

	/* loop through all exits */
	for (entity e = world; (e = find(e, ::classname, exitname));) {
		/* if it's not places by our owner... */
		if (e.real_owner != real_owner)
			continue;

		target = (TFCTeleporter)e;
		break;
	}

	if (!target)
		return;

	/* teleport our player */
	setorigin(eToucher, target.origin + [0,0,32]);

	/* if the teleport was successful, make them unusable for 2.5 secs */
	target.m_flNextTeleport = m_flNextTeleport = time + 2.5f;

}

void
TFCTeleporter::Place(player pl)
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
TFCTeleporter::FinishPlacing(void)
{
	env_message_single(real_owner, "You built the entrance, sonny!");
	Sound_Play(this, CHAN_BODY, "engineer.turret_set");
}

void
TFCTeleporter::TFCTeleporter(void)
{
	SetModel("models/dispenser.mdl");
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-16,-16,0], [16,16,48]);
}


/* exit only */
class
TFCTeleporterExit:TFCTeleporter
{
	void(void) TFCTeleporterExit;
	virtual void(void) FinishPlacing;
};

void
TFCTeleporterExit::FinishPlacing(void)
{
	env_message_single(real_owner, "You built the exit, sonny!");
	Sound_Play(this, CHAN_BODY, "engineer.turret_set");
}

void
TFCTeleporterExit::TFCTeleporterExit(void)
{
	SetModel("models/dispenser.mdl");
	SetSolid(SOLID_TRIGGER);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-16,-16,0], [16,16,48]);
}

void
CSEv_TFC_BuildTele_(void)
{
	player pl = (player)self;

	/* only engineers can do this */
	if (pl.classtype != CLASS_ENGINEER)
		return;

	/* it costs */
	if (pl.m_iAmmoCells < TFC_TELEPORTER_COST) {
		env_message_single(pl, "#Build_nometal");
		return;
	}

	/* can't build in the air */
	if (!(pl.flags & FL_ONGROUND)) {
		env_message_single(pl, "#Build_air");
		return;
	}

	if (TFC_ExistsForPlayer(pl, "TFCTeleport")) {
		env_message_single(pl, "You can only have one teleporter.");
		return;
	}

	pl.m_iAmmoCells -= TFC_TELEPORTER_COST;

	/* deploy */
	TFCTeleporter start = spawn(TFCTeleporter);
	start.Place(pl);
} 


void
CSEv_TFC_BuildTeleExit_(void)
{
	player pl = (player)self;

	/* only engineers can do this */
	if (pl.classtype != CLASS_ENGINEER)
		return;

	/* it costs */
	if (pl.m_iAmmoCells < TFC_TELEPORTER_COST) {
		env_message_single(pl, "#Build_nometal");
		return;
	}

	/* can't build in the air */
	if (!(pl.flags & FL_ONGROUND)) {
		env_message_single(pl, "#Build_air");
		return;
	}

	if (TFC_ExistsForPlayer(pl, "TFCTeleportExit")) {
		env_message_single(pl, "You can only have one teleporter exit.");
		return;
	}

	pl.m_iAmmoCells -= TFC_TELEPORTER_COST;

	/* deploy */
	TFCTeleporterExit end = spawn(TFCTeleporterExit);
	end.Place(pl);
} 
