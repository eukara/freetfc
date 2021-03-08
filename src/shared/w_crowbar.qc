/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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
	CBAR_IDLE,
	CBAR_DRAW,
	CBAR_HOLSTER,
	CBAR_ATTACK1HIT,
	CBAR_ATTACK1MISS,
	CBAR_ATTACK2MISS,
	CBAR_ATTACK2HIT,
	CBAR_ATTACK3MISS,
	CBAR_ATTACK3HIT
};

void
w_crowbar_precache(void)
{
	precache_sound("weapons/cbar_miss1.wav");
	precache_sound("weapons/cbar_hit1.wav");
	precache_sound("weapons/cbar_hit2.wav");
	precache_sound("weapons/cbar_hitbod1.wav");
	precache_sound("weapons/cbar_hitbod2.wav");
	precache_sound("weapons/cbar_hitbod3.wav");
	precache_model("models/v_tfc_crowbar.mdl");
	precache_model("models/w_crowbar.mdl");
	precache_model("models/p_crowbar.mdl");
}

void
w_crowbar_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, __NULL__, __NULL__, __NULL__);
#endif
}

string
w_crowbar_wmodel(void)
{
	return "models/w_crowbar.mdl";
}
string
w_crowbar_pmodel(void)
{
	return "models/p_crowbar.mdl";
}

string
w_crowbar_deathmsg(void)
{
	return "%s was assaulted by %s's Crowbar.";
}

void
w_crowbar_draw(void)
{
	Weapons_SetModel("models/v_tfc_crowbar.mdl");
	Weapons_ViewAnimation(CBAR_DRAW);
}

void
w_crowbar_holster(void)
{
	Weapons_ViewAnimation(CBAR_HOLSTER);
}

void
w_crowbar_primary(void)
{
	int anim = 0;
	vector src;
	player pl = (player)self;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors();
	src = pl.origin + pl.view_ofs;
	traceline(src, src + (v_forward * 32), FALSE, pl);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		anim = trace_fraction >= 1 ? CBAR_ATTACK1MISS:CBAR_ATTACK1HIT;
		break;
	case 1:
		anim = trace_fraction >= 1 ? CBAR_ATTACK2MISS:CBAR_ATTACK2HIT;
		break;
	default:
		anim = trace_fraction >= 1 ? CBAR_ATTACK3MISS:CBAR_ATTACK3HIT;
	}
	Weapons_ViewAnimation(anim);

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.5f;
	} else {
		pl.w_attack_next = 0.25f;
	}

	pl.w_idle_next = 2.5f;

#ifdef SERVER
	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTopTemp(ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTopTemp(ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

	sound(pl, CHAN_WEAPON, "weapons/cbar_miss1.wav", 1, ATTN_NORM);

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	} else {
		FX_Impact(IMPACT_MELEE, trace_endpos, trace_plane_normal);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, self, 10, WEAPON_CROWBAR, DMG_BLUNT);

		if (!trace_ent.iBleeds) {
			return;
		}

		if (random() < 0.33) {
			sound(pl, 8, "weapons/cbar_hitbod1.wav", 1, ATTN_NORM);
		} else if (random() < 0.66) {
			sound(pl, 8, "weapons/cbar_hitbod2.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/cbar_hitbod3.wav", 1, ATTN_NORM);
		}
	} else {
		if (random() < 0.5) {
			sound(pl, 8, "weapons/cbar_hit1.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/cbar_hit2.wav", 1, ATTN_NORM);
		}
	}
#endif
}

void
w_crowbar_release(void)
{
	player pl = (player)self;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(CBAR_IDLE);
	pl.w_idle_next = 15.0f;
}

float
w_crowbar_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_crowbar_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hud4.spr_0.tga",
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
			"sprites/640hud1.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_crowbar =
{
	.name		= "crowbar",
	.id			= ITEM_CROWBAR,
	.slot		= 0,
	.slot_pos	= 0,
	.draw		= w_crowbar_draw,
	.holster	= w_crowbar_holster,
	.primary	= w_crowbar_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_crowbar_release,
	.crosshair	= __NULL__,
	.precache	= w_crowbar_precache,
	.pickup		= __NULL__,
	.updateammo	= w_crowbar_updateammo,
	.wmodel		= w_crowbar_wmodel,
	.pmodel		= w_crowbar_pmodel,
	.deathmsg	= w_crowbar_deathmsg,
	.aimanim	= w_crowbar_aimanim,
	.hudpic		= w_crowbar_hudpic
};
