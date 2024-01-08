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
w_autorifle_precache(void)
{
	precache_model("models/v_tfc_sniper.mdl");
	precache_model("models/p_sniper2.mdl");
	Sound_Precache("weapon_sniper.fire");
}

void
w_autorifle_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoShells, __NULL__);
}

string
w_autorifle_wmodel(void)
{
	return "";
}
string
w_autorifle_pmodel(player pl)
{
	return "models/p_sniper2.mdl";
}

string
w_autorifle_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_autorifle_release(player pl)
{
	if (pl.w_idle_next > 0)
		return;

	Weapons_ViewAnimation(pl, SNIPER_AUTOIDLE);
}

void
w_autorifle_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_sniper.mdl");
	Weapons_ViewAnimation(pl, SNIPER_AUTODRAW);
	pl.w_idle_next = 1.0f;
}

float
w_autorifle_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? TFCANIM_CR_AIMAUTOSNIPER : TFCANIM_AIMAUTOSNIPER;
}

void
w_autorifle_primary(player pl)
{
	int s = w_baseauto_fire(WEAPON_AUTORIFLE, player::m_iAmmoShells, 8, [0,0]);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
	case AUTO_LAST:
		Weapons_ViewAnimation(pl, SNIPER_AUTOFIRE);

		if (pl.flags & FL_CROUCHING)
			Animation_PlayerTop(pl, TFCANIM_CR_SHOOTAUTOSNIPER, 0.45f);
		else
			Animation_PlayerTop(pl, TFCANIM_SHOOTAUTOSNIPER, 0.45f);

		#ifdef CLIENT
		View_SetMuzzleflash(MUZZLE_RIFLE);
		#endif
		Weapons_Sound(pl, CHAN_WEAPON, "weapon_sniper.fire");
		pl.w_attack_next = 0.1f;
		break;
	case AUTO_EMPTY:
		w_autorifle_release(pl);
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 0.0f;
}

void
w_autorifle_postdraw(player pl)
{
#ifdef CLIENT
	// crosshair
	if (pl.viewzoom == 1) {
		Cross_DrawSub(g_cross_spr, [24,24], [72/128,0], [0.1875, 0.1875]);
	} else {
		Cross_DrawSub(g_cross_spr, [104,16], [24/128,96/128], [104/128, 16/128]);
	}
	// ammo counter
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_autorifle_hudpic(player pl, int selected, vector pos, float a)
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

weapon_t w_autorifle =
{
	.name		= "autorifle",
	.id		= ITEM_AUTORIFLE,
	.slot		= 2,
	.slot_pos	= 0,
	.weight		= WEIGHT_AUTORIFLE,
	.draw		= w_autorifle_draw,
	.holster	= __NULL__,
	.primary	= w_autorifle_primary,
	.secondary	= w_autorifle_release,
	.reload		= __NULL__,
	.release	= w_autorifle_release,
	.postdraw	= w_autorifle_postdraw,
	.precache	= w_autorifle_precache,
	.pickup		= __NULL__,
	.updateammo	= w_autorifle_updateammo,
	.wmodel		= __NULL__,
	.pmodel		= w_autorifle_pmodel,
	.deathmsg	= w_autorifle_deathmsg,
	.aimanim	= w_autorifle_aimanim,
	.hudpic		= w_autorifle_hudpic,
	.isempty	= w_asscan_isempty
};
