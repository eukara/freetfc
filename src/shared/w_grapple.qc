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

void
w_grapple_precache(void)
{
	precache_model("models/v_grapple.mdl");
	precache_model("models/w_grapple.mdl");
	precache_model("models/p_grapple.mdl");
}

void
w_grapple_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_grapple_wmodel(void)
{
	return "models/w_grapple.mdl";
}
string
w_grapple_pmodel(player pl)
{
	return "models/p_grapple.mdl";
}

string
w_grapple_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_grapple_draw(player pl)
{
	Weapons_SetModel("models/v_grapple.mdl");
	Weapons_ViewAnimation(pl, 0);
}

float
w_grapple_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_grapple_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud4_spr,
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

weapon_t w_grapple =
{
	.name		= "grapple",
	.id		= ITEM_GRAPPLE,
	.slot		= 5,
	.slot_pos	= 0,
	.weight		= WEIGHT_GRAPPLE,
	.draw		= w_grapple_draw,
	.holster	= __NULL__,
	.primary	= __NULL__,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.postdraw	= __NULL__,
	.precache	= w_grapple_precache,
	.pickup		= __NULL__,
	.updateammo	= w_grapple_updateammo,
	.wmodel		= w_grapple_wmodel,
	.pmodel		= w_grapple_pmodel,
	.deathmsg	= w_grapple_deathmsg,
	.aimanim	= w_grapple_aimanim,
	.hudpic		= w_grapple_hudpic,
	.isempty	= w_asscan_isempty
};
