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
	SNIPER_IDLE,
	SNIPER_AIM,
	SNIPER_FIRE,
	SNIPER_DRAW,
	SNIPER_HOLSTER,
	SNIPER_AUTOIDLE,
	SNIPER_AUTOFIRE,
	SNIPER_AUTODRAW,
	SNIPER_AUTOHOLSTER,
};

void
w_sniper_precache(void)
{
	precache_model("models/v_tfc_sniper.mdl");
	precache_model("models/p_sniper.mdl");
	Sound_Precache("weapon_sniper.fire");
}

void
w_sniper_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoShells, __NULL__);
}

string
w_sniper_wmodel(void)
{
	return;
}
string
w_sniper_pmodel(player pl)
{
	return "models/p_sniper.mdl";
}

string
w_sniper_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_sniper_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_sniper.mdl");
	Weapons_ViewAnimation(pl, SNIPER_DRAW);
	pl.w_idle_next = 1.0f;
}

float
w_sniper_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? TFCANIM_CR_AIMSNIPER : TFCANIM_AIMSNIPER;
}

void
w_sniper_release(player pl)
{
	if (pl.w_idle_next > 0.0)
		return;

	if (pl.mode_tempstate > 0) {
		float dmg = bound(75, (pl.mode_tempstate/2) * 75, 375);
		w_baseauto_fire(pl, player::m_iAmmoShells, dmg, [0,0]);
		Weapons_ViewAnimation(pl, SNIPER_FIRE);

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, TFCANIM_CR_SHOOTSNIPER, 0.45f);
		else
			Animation_PlayerTop(pl, TFCANIM_SHOOTSNIPER, 0.45f);

		#ifdef CLIENT
		View_SetMuzzleflash(MUZZLE_RIFLE);
		#endif
		Weapons_Sound(pl, CHAN_WEAPON, "weapon_sniper.fire");
		pl.w_attack_next = 2.0f;
		pl.w_idle_next = 0.5f;
		pl.mode_tempstate = 0;
	}
}

void
w_sniper_primary(player pl)
{
	/* when moving, immediately release */
	if (vlen(pl.velocity) > 0) {
		w_sniper_release(pl);
		return;
	}

	/* weapon speed check */
	if (pl.w_attack_next > 0.0)
		return;

	/* if we aren't already, 'aim' down... */

	pl.mode_tempstate += 1;
	pl.w_attack_next = 1.0f;

	if (pl.mode_tempstate == 0) {
		Weapons_ViewAnimation(pl, SNIPER_AIM);
		pl.w_idle_next = pl.w_attack_next;
	}
}

void
w_sniper_secondary(player pl)
{
	if (!(input_buttons & INPUT_BUTTON0)) {
		if (pl.mode_tempstate != 0) {
			w_sniper_release(pl);
			return;
		}
	}

	if (pl.w_idle_next > 0) {
		return;
	}

	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}

	pl.w_idle_next = 0.25f;
}

void
w_sniper_postdraw(player pl)
{
#ifdef CLIENT
	Cross_DrawSub(g_cross_spr, [24,24], [72/128,0], [0.1875, 0.1875]);

	if (pl.mode_tempstate) {
		vector laser_pos;
		float lerp;
		vector jitter = [0.0f, 0.0f, 0.0f];
		Weapons_MakeVectors(pl);
		vector src = pl.origin + pl.view_ofs;
		float a = bound(0.0, (pl.mode_tempstate / 10), 1.0) * 0.75;
		traceline(src, src + (v_forward * 256), FALSE, pl);
		lerp = Math_Lerp(32,16, trace_fraction);
		jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
		jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
		laser_pos = g_hudmins + (g_hudres / 2) + ([-lerp,-lerp] / 2);

		drawsubpic(
			laser_pos + jitter,
			[lerp,lerp],
			g_laser_spr,
			[0,0],
			[1.0, 1.0],
			[1,1,1] * (0.25 + a),
			1.0,
			DRAWFLAG_ADDITIVE
		);
	}

	// ammo counter
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_sniper_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud2_spr,
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
			g_tfchud1_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_sniper =
{
	.name		= "sniper",
	.id		= ITEM_SNIPER,
	.slot		= 1,
	.slot_pos	= 1,
	.draw		= w_sniper_draw,
	.holster	= __NULL__,
	.primary	= w_sniper_primary,
	.secondary	= w_sniper_secondary,
	.reload		= __NULL__,
	.release	= w_sniper_release,
	.postdraw	= w_sniper_postdraw,
	.precache	= w_sniper_precache,
	.pickup		= __NULL__,
	.updateammo	= w_sniper_updateammo,
	.wmodel		= __NULL__,
	.pmodel		= w_sniper_pmodel,
	.deathmsg	= w_sniper_deathmsg,
	.aimanim	= w_sniper_aimanim,
	.hudpic		= w_sniper_hudpic,
	.isempty	= w_asscan_isempty
};
