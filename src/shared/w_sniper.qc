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
w_sniper_release(player pl)
{
	Weapons_ViewAnimation(pl, SNIPER_IDLE);
}

void
w_sniper_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_sniper.mdl");
	Weapons_ViewAnimation(pl, SNIPER_IDLE);
}

float
w_sniper_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_sniper_primary(player pl)
{

//pl.mode_still = 1 - pl.mode_still;

// TODO
// Below should be in the release, we need to detect whether we are still and then create the "dot"

	if (pl.w_attack_next > 0.0)
		return;

	w_baseauto_fire(pl, player::m_iAmmoShells, 8, [0,0]);
	Weapons_ViewAnimation(pl, SNIPER_FIRE);
	#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
	#endif
	Weapons_Sound(pl, CHAN_WEAPON, "weapon_sniper.fire");
	pl.w_attack_next = 2.0f;

	pl.w_idle_next = 1.5f;

}

void
w_sniper_secondary(player pl)
{
	if (pl.w_attack_next) {
		return;
	}
	/* Simple toggle of fovs */
	if (pl.viewzoom == 1.0f) {
		pl.viewzoom = 0.2f;
	} else {
		pl.viewzoom = 1.0f;
	}
	pl.w_attack_next = 0.5f;
}

/*
void
w_sniper_release(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;

// Can't fire if moving
//if (pl.mode_still == 1) {
	w_baseauto_fire(pl, player::m_iAmmoShells, 8, [0,0]);
	Weapons_ViewAnimation(pl, SNIPER_FIRE);
	#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_WEIRD);
	#else
	Sound_Play(pl, CHAN_WEAPON, "weapon_sniper.fire");
	#endif
	pl.w_attack_next = 2.0f;
//}
	pl.w_idle_next = 1.5f;
}
*/
void
w_sniper_postdraw(player pl)
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
w_sniper_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud02.spr_0.tga",
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
			"sprites/tfchud01.spr_0.tga",
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
	.release	= __NULL__,
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
