/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
 * Copyright (c) 2022 Gethyn ThomasQuail <xylemon@posteo.net>
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
	WRENCH_IDLE,
	WRENCH_ATTACK1,
	WRENCH_ATTACK2,
	WRENCH_USE,
	WRENCH_DRAW,
	WRENCH_HOLSTER
};

void
w_wrench_precache(void)
{
	precache_sound("weapons/cbar_miss1.wav");
	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hit2.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_hitbod2.wav");
	precache_sound("weapons/cbar_hitbod3.wav");
	precache_model("models/v_tfc_spanner.mdl");
	precache_model("models/p_spanner.mdl");
}

void
w_wrench_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoCells, __NULL__);
}

string
w_wrench_wmodel(void)
{
	return "models/ball.mdl";
}
string
w_wrench_pmodel(player pl)
{
	return "models/p_spanner.mdl";
}

string
w_wrench_deathmsg(void)
{
	return "%s was assaulted by %s's wrench.";
}

void
w_wrench_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_spanner.mdl");
	Weapons_ViewAnimation(pl, WRENCH_DRAW);
}

void
w_wrench_holster(player pl)
{
	Weapons_ViewAnimation(pl, WRENCH_HOLSTER);
}

void
w_wrench_primary(player pl)
{
	int anim = 0;
	vector src;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		anim = WRENCH_ATTACK1;
		break;
	default:
		anim = WRENCH_ATTACK2;
	}
	Weapons_ViewAnimation(pl, anim);

	if (trace_fraction < 1.0) {
		pl.w_attack_next = 0.25f;
	} else {
		pl.w_attack_next = 0.5f;
	}

	pl.w_idle_next = 2.5f;

#ifdef SERVER
	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

	sound(pl, CHAN_WEAPON, "weapons/cbar_miss1.wav", 1, ATTN_NORM);

	if (trace_fraction >= 1.0) {
		return;
	}

	if (trace_ent.classname == "TFCSentry") {
		TFCSentry sentry = (TFCSentry)trace_ent;
		/* todo 
	} else if (trace_ent.classname == "TFCDispenser") {
		TFCDispenser dispenser = (TFCDispenser)trace_ent;
		todo
	} else if (trace_ent.classname == "TFCTeleporter") {
		TFCTeleporter teleporter = (TFCTeleporter)trace_ent;
		todo
	} else if (trace_ent.classname == "TFCTeleporterExit") {
		TFCTeleporterExit teleporterexit = (TFCTeleporterExit)trace_ent;
		todo */
	} else {
		/* don't bother with decals, we got squibs */
		if (trace_ent.iBleeds) {
			FX_Blood(trace_endpos, [1,0,0]);
		} else {
			FX_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
		}

		/* Damage without armor is between 12 - 20, so let's just do 15 for now */
		if (trace_ent.takedamage) {
			Damage_Apply(trace_ent, pl, 18, WEAPON_WRENCH, DMG_BLUNT);
			if (trace_ent.iBleeds) {
				Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hitbody");
			}
		} else {
			Sound_Play(self, CHAN_WEAPON, "weapon_crowbar.hit");
		}
	}

#endif
}

void
w_wrench_release(player pl)
{

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(pl, WRENCH_IDLE);
	pl.w_idle_next = 15.0f;
}

void
w_wrench_crosshair(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	drawsubpic(
		aicon_pos,
		[24,24],
		g_hud7_spr,
		[0,96/128],
		[24/256,24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);

	HUD_DrawAmmo2();
#endif
}

float
w_wrench_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void 
w_wrench_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud4_spr,
			[0,180/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud3_spr,
			[0,135/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.m_iAmmoCells, MAX_A_CELLS, a);
#endif
}

weapon_t w_wrench =
{
	.name		= "wrench",
	.id		= ITEM_WRENCH,
	.slot		= 0,
	.slot_pos	= 3,
	.draw		= w_wrench_draw,
	.holster	= w_wrench_holster,
	.primary	= w_wrench_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_wrench_release,
	.postdraw	= w_wrench_crosshair,
	.precache	= w_wrench_precache,
	.pickup		= __NULL__,
	.updateammo	= w_wrench_updateammo,
	.wmodel		= w_wrench_wmodel,
	.pmodel		= w_wrench_pmodel,
	.deathmsg	= w_wrench_deathmsg,
	.aimanim	= w_wrench_aimanim,
	.hudpic		= w_wrench_hudpic,
	.isempty	= w_asscan_isempty
};
