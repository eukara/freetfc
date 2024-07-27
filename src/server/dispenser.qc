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
	float m_flNextDispense;

	int m_iShells;
	int m_iNails;
	int m_iRockets;
	int m_iCells;
	int m_iArmor;

	void TFCDispenser(void);

	virtual void Place(TFPlayer);
	virtual void FinishPlacing(void);

	virtual void Touch(entity);

	virtual void Replenish(void);
	virtual void ClampValues(void);

	virtual int GrabShells(void);
	virtual int GrabNails(void);
	virtual int GrabRockets(void);
	virtual int GrabCells(void);
	virtual int GrabArmor(void);

	virtual void Death(entity, entity, int, vector, int);
};

void
TFCDispenser::Death(entity inflictor, entity attacker, int damage, vector dir, int location)
{
	env_message_single(real_owner, "#Dispenser_destroyed");
	pointparticles(particleeffectnum("fx_explosion.main"), origin, [0,0,0], 1);
	Destroy();
}

int
TFCDispenser::GrabShells(void)
{
	int iOut = 20;

	if (m_iShells >= 20) {
		m_iShells -= 20;
	} else {
		iOut = m_iShells;
		m_iShells = 0;
	}

	return iOut;
}

int
TFCDispenser::GrabNails(void)
{
	int iOut = 20;

	if (m_iNails >= 20) {
		m_iNails -= 20;
	} else {
		iOut = m_iNails;
		m_iNails = 0;
	}

	return iOut;
}

int
TFCDispenser::GrabRockets(void)
{
	int iOut = 10;

	if (m_iRockets >= 10) {
		m_iRockets -= 10;
	} else {
		iOut = m_iRockets;
		m_iRockets = 0;
	}

	return iOut;
}

int
TFCDispenser::GrabCells(void)
{
	int iOut = 20;

	if (m_iCells >= 20) {
		m_iCells -= 20;
	} else {
		iOut = m_iCells;
		m_iCells = 0;
	}

	return iOut;
}

int
TFCDispenser::GrabArmor(void)
{
	int iOut = 20;

	if (m_iArmor >= 20) {
		m_iArmor -= 20;
	} else {
		iOut = m_iArmor;
		m_iArmor = 0;
	}

	return iOut;
}

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
	m_iShells += 1;
	m_iNails += 1;
	m_iRockets += 1;
	m_iCells += 1;
	m_iArmor += 1;
	ClampValues();
	ScheduleThink(Replenish, 1.0f);
}

void
TFCDispenser::Touch(entity eToucher)
{
	if (eToucher.team != real_owner.team)
		return;

	if (m_flNextDispense > time)
		return;

	TFPlayer pl = (TFPlayer)eToucher;
	int rocketType = ammoNumForName("ammo_rockets");
	int nailType = ammoNumForName("ammo_nails");
	int cellType = ammoNumForName("ammo_cells");
	int shellType = ammoNumForName("ammo_shells");

	int r, n, c, s, a, sum;
	r = n = c = s = a = sum = 0;

	/* only subtract what if we need anything */
	if (pl.GetReserveAmmo(rocketType) < pl.m_iMaxRockets)
		r = GrabRockets();
	if (pl.GetReserveAmmo(nailType) < pl.m_iMaxNails)
		n = GrabNails();
	if (pl.GetReserveAmmo(cellType) < pl.m_iMaxCells)
		c = GrabCells();
	if (pl.GetReserveAmmo(shellType) < pl.m_iMaxShells)
		s = GrabShells();
	if (pl.armor < pl.m_iMaxArmor)
		a = GrabArmor();

	/* see the sum of what we picked up to determine if we'll register as a pickup */
	sum = r + n + c + s + a;

	/* check */
	if (sum <= 0)
		return;

	sound(this, CHAN_ITEM, "weapons/scock1.wav", 1.0, ATTN_NORM);

	/* add whatever it is we can get */
	pl.GiveAmmo(rocketType, r);
	pl.GiveAmmo(nailType, n);
	pl.GiveAmmo(cellType, c);
	pl.GiveAmmo(shellType, s);
	pl.armor += a;

	if (pl.armor > pl.m_iMaxArmor)
		pl.armor = pl. m_iMaxArmor;

	m_flNextDispense = time + 2.0f;
}

void
TFCDispenser::Place(TFPlayer pl)
{
	vector newAngles = pl.GetAngles();
	newAngles[0] = newAngles[2] = 0;
	SetAngles(newAngles);

	makevectors([0, pl.v_angle[1], 0]);
	SetOrigin(pl.origin + (v_forward * 48));
	DropToFloor();

	ScheduleThink(FinishPlacing, 5.0f);
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
	ScheduleThink(Replenish, 1.0f);
}

void
TFCDispenser::TFCDispenser(void)
{
	SetModel("models/dispenser.mdl");
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetSize([-16,-16,0], [16,16,48]);
	SetHealth(150);
	SetTakedamage(DAMAGE_YES);
}

void
TFCDispenser_Build(void)
{
	TFPlayer pl = (TFPlayer)self;
	int cellType = ammoNumForName("ammo_cells");

	/* only engineers can do this */
	if (pl.classtype != CLASS_ENGINEER)
		return;

	/* it costs cells to build these things */
	if (pl.UseAmmo(cellType, TFC_DISPENSER_COST) == false) {
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

	/* deploy */
	TFCDispenser dispenser = spawn(TFCDispenser);
	dispenser.Place(pl);
}

void
TFCDispenser_Dismantle(void)
{
	TFC_DetonateTypeForPlayer((TFPlayer)self, "TFCDispenser");
}
