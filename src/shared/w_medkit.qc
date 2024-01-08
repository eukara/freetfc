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
	MEDKIT_IDLE1,
	MEDKIT_IDLE2,
	MEDKIT_USE,
	MEDKIT_UNUSED,
	MEDKIT_HOLSTER,
	MEDKIT_DRAW
};

void
w_medkit_precache(void)
{
	precache_model("models/v_tfc_medkit.mdl");
	precache_model("models/w_medkit.mdl");
	precache_model("models/p_medkit.mdl");
}

void
w_medkit_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_medkit_wmodel(void)
{
	return "models/w_medkit.mdl";
}
string
w_medkit_pmodel(player pl)
{
	return "models/p_medkit.mdl";
}

string
w_medkit_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_medkit_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_medkit.mdl");
	Weapons_ViewAnimation(pl, 0);
}

void
w_medkit_primary(player pl)
{
	vector src;

	if (pl.w_attack_next > 0.0)
		return;

 // cast our traceline
	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;

	traceline(src, src + (v_forward * 64), FALSE, pl);

	Weapons_ViewAnimation(pl, MEDKIT_USE);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, TFCANIM_CR_SHOOTMEDKIT, 0.45f);
	else
		Animation_PlayerTop(pl, TFCANIM_SHOOTMEDKIT, 0.45f);

	if (trace_ent.classname == "player") {
		player otherpl = (player) trace_ent;

	#ifdef SERVER
		if (otherpl.GetTeam() == pl.GetTeam()) {
			/* Don't give the player more than 100% health */
			if (otherpl.health < otherpl.m_iMaxHealth) {
				/* We want to only give health to our teammate & skip armor */
				otherpl.health = bound(0, otherpl.health + 15, otherpl.m_iMaxHealth);
			}
		} else {
			/* Poison the enemey */
			// TODO
			// Needs to last for 10+ seconds and spread to others
			Damage_Apply(otherpl, pl, 15, WEAPON_MEDKIT, DMG_GENERIC);
		}
		Weapons_Sound(pl, CHAN_WEAPON, "weapon_medkit.heal");
	#endif
	}
	pl.w_attack_next = 0.4f;
	pl.w_idle_next = 5.0f;
}

void
w_medkit_release(player pl)
{

	if (pl.w_idle_next > 0.0)
		return;

	int r = (float)input_sequence % 2;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, MEDKIT_IDLE1);
		pl.w_idle_next = 1.16f;
		break;
	default:
		Weapons_ViewAnimation(pl, MEDKIT_IDLE2);
		pl.w_idle_next = 2.36f;
		break;
	}
}

float
w_medkit_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? TFCANIM_CR_AIMMEDKIT : TFCANIM_AIMMEDKIT;
}

void
w_medkit_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud5_spr,
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
			g_tfchud6_spr,
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_medkit =
{
	.name		= "medkit",
	.id		= ITEM_MEDKIT,
	.slot		= 0,
	.slot_pos	= 1,
	.weight		= WEIGHT_MEDKIT,
	.draw		= w_medkit_draw,
	.holster	= __NULL__,
	.primary	= w_medkit_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_medkit_release,
	.postdraw	= __NULL__,
	.precache	= w_medkit_precache,
	.pickup		= __NULL__,
	.updateammo	= w_medkit_updateammo,
	.wmodel		= w_medkit_wmodel,
	.pmodel		= w_medkit_pmodel,
	.deathmsg	= w_medkit_deathmsg,
	.aimanim	= w_medkit_aimanim,
	.hudpic		= w_medkit_hudpic,
	.isempty	= w_asscan_isempty
};
