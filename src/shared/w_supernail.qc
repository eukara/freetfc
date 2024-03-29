/*
 * Copyright (c) 2016-2024 Marco Cawthorne <marco@icculus.org>
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
w_supernail_precache(void)
{
#ifdef CLIENT
	precache_model("models/v_tfc_supernailgun.mdl");
#else
	precache_model("models/w_supernail.mdl");
	precache_model("models/p_supernail.mdl");
	precache_model("models/nail.mdl");
	Sound_Precache("weapon_nailgun.fire");
#endif
}

void
w_supernail_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoNails, __NULL__);
}

string
w_supernail_wmodel(void)
{
	return "models/p_snailgun2.mdl";
}
string
w_supernail_pmodel(player pl)
{
	return "models/p_snailgun2.mdl";
}

string
w_supernail_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_supernail_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_supernailgun.mdl");
	Weapons_ViewAnimation(pl, NAILGUN_DEPLOY);
}

float
w_supernail_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? TFCANIM_CR_AIMMP5 : TFCANIM_AIMMP5;
}

void
w_supernail_shootnail(player pl)
{
	static void w_rpg_shootrocket_touch(void) {
		#ifndef CLIENT
		/* impact per bullet */
		if (trace_ent.iBleeds == 0) {
			DecalGroups_Place("Impact.BigShot", trace_endpos + (v_forward * -2));
			SurfData_Impact(trace_ent, trace_endpos, trace_plane_normal);
		}
		if (trace_ent.takedamage == DAMAGE_YES) {
			Damage_Apply(trace_ent, self.owner, 14, WEAPON_NAILGUN, DMG_BULLET);
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
w_supernail_primary(player pl)
{
	int s = w_baseprojectile_fire_num(pl, WEAPON_NAILGUN, player::m_iAmmoNails, w_supernail_shootnail, 2);

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

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, TFCANIM_CR_SHOOTMP5, 0.45f);
		else
			Animation_PlayerTop(pl, TFCANIM_SHOOTMP5, 0.45f);

		#ifdef CLIENT
		View_SetMuzzleflash(MUZZLE_RIFLE);
		#endif
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
w_supernail_hud(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	Cross_DrawSub(g_cross_spr, [24,24], [0.1875,0], [0.1875, 0.1875]);
	HUD_DrawAmmo2();

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[0,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

void
w_supernail_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud7_spr,
			[0,135/256],
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
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_supernail =
{
	.name		= "supernail",
	.id		= ITEM_SUPERNAIL,
	.slot		= 3,
	.slot_pos	= 2,
	.weight		= WEIGHT_SUPERNAIL,
	.draw		= w_supernail_draw,
	.holster	= __NULL__,
	.primary	= w_supernail_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.postdraw	= w_supernail_hud,
	.precache	= w_supernail_precache,
	.pickup		= __NULL__,
	.updateammo	= w_supernail_updateammo,
	.wmodel		= w_supernail_wmodel,
	.pmodel		= w_supernail_pmodel,
	.deathmsg	= w_supernail_deathmsg,
	.aimanim	= w_supernail_aimanim,
	.hudpic		= w_supernail_hudpic,
	.isempty	= w_asscan_isempty
};
