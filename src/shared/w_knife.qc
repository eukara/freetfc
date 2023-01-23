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
	KNIFE_IDLE,
	KNIFE_IDLE2,
	KNIFE_SLASH,
	KNIFE_STAB,
	KNIFE_DRAW,
	KNIFE_HOLSTER
};

void
w_knife_precache(void)
{
	Sound_Precache("weapon_crowbar.hit");
	Sound_Precache("weapon_crowbar.miss");
	Sound_Precache("weapon_crowbar.hitbody");
	precache_model("models/v_tfc_knife.mdl");
	precache_model("models/w_knife.mdl");
	precache_model("models/p_knife.mdl");
}

void
w_knife_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_knife_wmodel(void)
{
	return "models/w_knife.mdl";
}
string
w_knife_pmodel(player pl)
{
	return "models/p_knife.mdl";
}

string
w_knife_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_knife_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_knife.mdl");
	Weapons_ViewAnimation(pl, KNIFE_DRAW);
}

void
w_knife_holster(player pl)
{
	Weapons_ViewAnimation(pl, KNIFE_HOLSTER);
}

void
w_knife_primary(player pl)
{
	int anim = 0;
	vector src;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;

	/* make sure we can gib corpses */
	int oldhitcontents = self.hitcontentsmaski;
	self.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	self.hitcontentsmaski = oldhitcontents;

	pl.w_attack_next = 0.4f;

	pl.w_idle_next = 2.5f;

	Weapons_ViewAnimation(pl, KNIFE_SLASH);

	if (pl.flags & FL_CROUCHING)
		Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.41f);
	else
		Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);

	Weapons_Sound(pl, CHAN_WEAPON, "weapon_crowbar.miss");

#ifdef SERVER

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	} else {
		FX_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
	}

	// Backstab detection
	if (trace_ent.takedamage) {
		int damage = 36;
		damageType_t dmgtype = DMG_BLUNT;

		if (trace_ent.classname == "player") {
			player otherpl = (player) trace_ent;
			if (otherpl.IsFacing(pl) == false) {
				damage = 500;
				dmgtype = DMG_CRUSH;
			}
		}
		Damage_Apply(trace_ent, pl, damage, WEAPON_KNIFE, dmgtype);
		if (trace_ent.iBleeds) {
			Weapons_Sound(pl, CHAN_WEAPON, "weapon_crowbar.hitbody");
		} else {
			Weapons_Sound(pl, CHAN_WEAPON, "weapon_crowbar.hit");
		}
	}
#endif
}

float
w_knife_aimanim(player pl)
{
	return pl.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_knife_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_tfchud4_spr,
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
			g_tfchud3_spr,
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_knife =
{
	.name		= "knife",
	.id		= ITEM_KNIFE,
	.slot		= 0,
	.slot_pos	= 2,
	.draw		= w_knife_draw,
	.holster	= w_knife_holster,
	.primary	= w_knife_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.postdraw	= __NULL__,
	.precache	= w_knife_precache,
	.pickup		= __NULL__,
	.updateammo	= w_knife_updateammo,
	.wmodel		= w_knife_wmodel,
	.pmodel		= w_knife_pmodel,
	.deathmsg	= w_knife_deathmsg,
	.aimanim	= w_knife_aimanim,
	.hudpic		= w_knife_hudpic,
	.isempty	= w_asscan_isempty
};
