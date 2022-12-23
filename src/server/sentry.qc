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

void
TFCSentry::Think(void)
{
	ScheduleThink(Think 0.1f);

	/* searching */
	entity t = world;
	{
		for (entity p = world; (p = find(p, ::classname, "player"));) {
			/* out of range */
			if (vlen(origin - p.origin) > 1024)
				continue;

			/* find them */
			traceline(origin, p.origin, MOVE_NORMAL, this);
			if (trace_ent == p) {
				t = p;
				break;
			}
		}
	}

	if (m_state == SENTRY_SEARCHING) {
		float twist = sin(time);
		m_eHead.SetBoneControl1(twist);
		m_eHead.SetBoneControl2(0.5f);

		if (m_flNextIdleSound < time) {
			Sound_Play(this, CHAN_VOICE, "turret_tfc.idle_noise");
			m_flNextIdleSound = time + 10.0f;
		}

		if (t)
			m_state = SENTRY_ALERTED;
	} else if (m_state == SENTRY_ALERTED) {
		Sound_Play(this, CHAN_VOICE, "turret_tfc.target_spotted");
		m_state = SENTRY_SHOOTING;
	} else if (m_state == SENTRY_SHOOTING) {
		// shoot things
		if (!t)
			m_state = SENTRY_SEARCHING;
		else {
			makevectors([0, angles[1], 0]);
			m_flWantAngle = dotproduct(normalize(origin - t.origin), v_right);
			m_flCurrAngle = Math_Lerp(m_flCurrAngle, m_flWantAngle, 0.25f);
			m_eHead.SetBoneControl1(m_flCurrAngle);

			/* fire bullets */
			v_angle = vectoangles(normalize(origin - t.origin));
			TraceAttack_FireBullets(1, origin, 5, [0.025,0.025], WEAPON_NONE);
		}
	}
}

void
TFCSentry::Place(NSClientPlayer pl)
{
	SetAngles(pl.GetAngles());

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
TFCSentry::FinishPlacing(void)
{
	/* put the top on that spins */
	m_eHead.SetModel("models/sentry1.mdl");
	m_eHead.SetAngles(GetAngles());
	m_eHead.SetSolid(SOLID_BBOX);
	m_eHead.SetMovetype(MOVETYPE_NONE);
	m_eHead.SetSize([-16,-16,0], [16,16,32]);
	m_eHead.SetOrigin(GetOrigin() + [0,0,20]);
	m_eHead.colormap = colormap;

	ScheduleThink(Think, 0.1f);
	m_state = SENTRY_SEARCHING;
	m_flNextIdleSound = time + 5.0f;

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

	SetTakedamage(DAMAGE_YES);
	SetHealth(100);
	m_eHead.SetTakedamage(DAMAGE_YES);
	m_eHead.SetHealth(100);
	m_state = SENTRY_IDLE;
}

void
TFCSentry_Build(void)
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

void
TFCSentry_Dismantle(void)
{
	TFC_DetonateTypeForPlayer((player)self, "TFCSentry");
}
