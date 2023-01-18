/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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
	NAILGUN_IDLE,
	NAILGUN_FIDGET1,
	NAILGUN_UNUSED1,
	NAILGUN_UNUSED2,
	NAILGUN_DEPLOY,
	NAILGUN_SHOOT1,
	NAILGUN_SHOOT2,
	NAILGUN_SHOOT3,
};

void
w_nailgun_precache(void)
{
	precache_model("models/v_tfc_nailgun.mdl");
	precache_model("models/w_nailgun.mdl");
	precache_model("models/p_nailgun.mdl");
	precache_model("models/nail.mdl");
	Sound_Precache("weapon_nailgun.fire");
}

void
w_nailgun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoNails, __NULL__);
}

string
w_nailgun_wmodel(void)
{
	return "models/w_nailgun.mdl";
}
string
w_nailgun_pmodel(player pl)
{
	return "models/p_nailgun.mdl";
}

string
w_nailgun_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_nailgun_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_nailgun.mdl");
	Weapons_ViewAnimation(pl, NAILGUN_DEPLOY);
}

float
w_nailgun_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_nailgun_shootnail(player pl)
{
	static void w_rpg_shootrocket_touch(void) {
		#ifndef CLIENT
		/* impact per bullet */
		if (trace_ent.iBleeds == 0) {
			DecalGroups_Place("Impact.BigShot", trace_endpos + (v_forward * -2));
			SurfData_Impact(trace_ent, trace_surfaceflagsi, trace_endpos, trace_plane_normal);
		}
		#endif
		remove(self);
	}

	Weapons_MakeVectors(pl);
	entity p = spawn();
	setmodel(p, "models/nail.mdl");
	setorigin(p, Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	p.owner = self;
	p.movetype = MOVETYPE_FLYMISSILE;
	p.solid = SOLID_BBOX;
	p.gravity = 0.5f;
	p.velocity = (v_forward * 1000) + (v_up * 4) + (v_right * -2);
	p.angles = vectoangles(p.velocity);
	p.touch = w_rpg_shootrocket_touch;
	p.think = Util_Destroy;
	p.nextthink = time + 5.0f;
}

void
w_nailgun_primary(player pl)
{
	int s = w_baseprojectile_fire(pl, WEAPON_NAILGUN, player::m_iAmmoNails, w_nailgun_shootnail);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
	case AUTO_LAST:
		int r = (float)input_sequence % 3;
		if (r == 1) {
			Weapons_ViewAnimation(pl, NAILGUN_SHOOT1);
		} else if (r == 2) {
			Weapons_ViewAnimation(pl, NAILGUN_SHOOT2);
		} else {
			Weapons_ViewAnimation(pl, NAILGUN_SHOOT3);
		}
		Weapons_ViewAnimation(pl, NAILGUN_SHOOT2);
		Weapons_ViewPunchAngle(pl, [-1,0,0]);
		#ifndef CLIENT
		Sound_Play(pl, CHAN_WEAPON, "weapon_nailgun.fire");
		#endif
		pl.w_attack_next = 0.1f;
		break;
	case AUTO_EMPTY:
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 1.5f;
}

void
w_nailgun_crosshair(player pl)
{
#ifdef CLIENT
	Cross_DrawSub(g_cross_spr, [24,24], [0.1875,0], [0.1875, 0.1875]);
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [0,72/128],[24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_nailgun_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud07.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud07.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_nailgun =
{
	.name		= "nailgun",
	.id		= ITEM_NAILGUN,
	.slot		= 3,
	.slot_pos	= 0,
	.draw		= w_nailgun_draw,
	.holster	= __NULL__,
	.primary	= w_nailgun_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.postdraw	= w_nailgun_crosshair,
	.precache	= w_nailgun_precache,
	.pickup		= __NULL__,
	.updateammo	= w_nailgun_updateammo,
	.wmodel		= w_nailgun_wmodel,
	.pmodel		= w_nailgun_pmodel,
	.deathmsg	= w_nailgun_deathmsg,
	.aimanim	= w_nailgun_aimanim,
	.hudpic		= w_nailgun_hudpic,
	.isempty	= w_asscan_isempty
};
