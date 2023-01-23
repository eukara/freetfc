/*
 * Copyright (c) 2016-2023 Marco Cawthorne <marco@icculus.org>
 * Copyright (c) 2023 Gethyn ThomasQuail <xylemon@posteo.net>
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

enum
{
	RAILGUN_IDLE,
	RAILGUN_SHOOT,
	RAILGUN_DRAW,
	RAILGUN_HOLSTER,
};

void
w_railgun_precache(void)
{
	precache_model("models/v_tfc_railgun.mdl");
	precache_model("models/w_railgun.mdl");
	precache_model("models/p_railgun.mdl");
	Sound_Precache("weapon_railgun.fire");
}

void
w_railgun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoNails, __NULL__);
}

string
w_railgun_wmodel(void)
{
	return "models/w_railgun.mdl";
}
string
w_railgun_pmodel(player pl)
{
	return "models/p_9mmhandgun.mdl";
}

string
w_railgun_deathmsg(void)
{
	return "%s was assaulted by %s's railgun.";
}

void
w_railgun_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_railgun.mdl");
	Weapons_ViewAnimation(pl, RAILGUN_DRAW);
}

float
w_railgun_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? TFCANIM_CR_AIM1HAND : TFCANIM_AIM1HAND;
}

void
w_railgun_shootbeam(player pl)
{
#ifdef SERVER
	static void w_railgun_shootbeam_touch(void) {
		#ifndef CLIENT
		/* impact per bullet */
		if (trace_ent.iBleeds == 0) {
			DecalGroups_Place("Impact.BigShot", trace_endpos + (v_forward * -2));
			SurfData_Impact(trace_ent, trace_surfaceflagsi, trace_endpos, trace_plane_normal);
		}
		if (trace_ent.takedamage == DAMAGE_YES) {
			Damage_Apply(trace_ent, self.owner, 23, WEAPON_RAILGUN, DMG_BULLET);
		}
		#endif
		remove(self);
	}

	Weapons_MakeVectors(pl);
	entity p = spawn();
	setmodel(p, "models/nail.mdl");
	setorigin(p, Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -5) + (v_right * 3.5));
	p.owner = self;
	p.movetype = MOVETYPE_FLYMISSILE;
	p.solid = SOLID_BBOX;
	p.gravity = 0.5f;
	p.velocity = (v_forward * 1000) + (v_up * 5) + (v_right * -3.5);
	p.angles = vectoangles(p.velocity);
	p.touch = w_railgun_shootbeam_touch;
	p.think = Util_Destroy;
	p.nextthink = time + 5.0f;
	p.alpha = 0.01f;
	p.traileffectnum = particleeffectnum("weapon_railgun.trail");
#endif
}

void
w_railgun_primary(player pl)
{
	int s = w_baseprojectile_fire(pl, WEAPON_RAILGUN, player::m_iAmmoNails, w_railgun_shootbeam);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
	case AUTO_LAST:
		int r = (float)input_sequence % 3;
		Weapons_ViewAnimation(pl, RAILGUN_SHOOT);
		Weapons_ViewPunchAngle(pl, [-1,0,0]);

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, TFCANIM_CR_SHOOT1HAND, 0.45f);
		else
			Animation_PlayerTop(pl, TFCANIM_SHOOT1HAND, 0.45f);

		Weapons_Sound(pl, CHAN_WEAPON, "weapon_railgun.fire");
		pl.w_attack_next = 0.4f;
		break;
	case AUTO_EMPTY:
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 1.5f;
}

void
w_railgun_postdraw(player pl)
{
#ifdef CLIENT
	// crosshair
	Cross_DrawSub(g_cross_spr, [24,24], [48/128,24/128], [0.1875, 0.1875]);
	// ammo counter
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,72/128],[24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_railgun_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud7_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud7_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_railgun =
{
	.name		= "railgun",
	.id		= ITEM_RAILGUN,
	.slot		= 1,
	.slot_pos	= 3,
	.draw		= w_railgun_draw,
	.holster	= __NULL__,
	.primary	= w_railgun_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.postdraw	= w_railgun_postdraw,
	.precache	= w_railgun_precache,
	.pickup		= __NULL__,
	.updateammo	= w_railgun_updateammo,
	.wmodel		= w_railgun_wmodel,
	.pmodel		= w_railgun_pmodel,
	.deathmsg	= w_railgun_deathmsg,
	.aimanim	= w_railgun_aimanim,
	.hudpic		= w_railgun_hudpic,
	.isempty	= w_asscan_isempty
};
