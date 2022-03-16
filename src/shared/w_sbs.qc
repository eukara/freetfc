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
	SBS_IDLE1,
	SBS_FIRE1,
	SBS_FIRE2,
	SBS_ADDSHELL,
	SBS_PUMP,
	SBS_START_RELOAD,
	SBS_DRAW,
	SBS_HOLSTER,
	SBS_IDLE2,
	SBS_IDLE3
};

void
w_sbs_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_sbs.cock");
	Sound_Precache("weapon_sbs.fire");
	Sound_Precache("weapon_sbs.reload");
#endif
	precache_model("models/v_tfc_12gauge.mdl");
	precache_model("models/p_shotgun.mdl");
	precache_sound("weapons/dbarrel1.wav");
}

void
w_sbs_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mag_sbs, pl.m_iAmmoShells, __NULL__);
}
string w_sbs_wmodel(void)
{
	return "models/ball.mdl";
}
string w_sbs_pmodel(player pl)
{
	return "models/p_shotgun.mdl";
}
string w_sbs_deathmsg(void)
{
	return "";
}

int
w_sbs_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	pl.mag_sbs = bound(0, pl.mag_sbs + 8, 8);
#endif
	return (1);
}

void
w_sbs_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_12gauge.mdl");
	Weapons_ViewAnimation(pl, SBS_DRAW);
}

void
w_sbs_holster(player pl)
{
	Weapons_ViewAnimation(pl, SBS_HOLSTER);
}

void
w_sbs_primary(player pl)
{
	int s = w_baseshotgun_fire(WEAPON_SBS, player::mag_sbs, 6, 4, [0.04, 0.04, 0]);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
		Weapons_ViewAnimation(pl, SBS_FIRE1);
		Weapons_ViewPunchAngle(pl, [-2,0,0]);
		//Weapons_Sound(pl, CHAN_WEAPON, "weapon_mossberg.fire");
		pl.w_attack_next = 0.5f;
		break;
	case AUTO_LAST:
		Weapons_ViewAnimation(pl, SBS_FIRE1);
		Weapons_ViewPunchAngle(pl, [-2,0,0]);
		//Weapons_Sound(pl, CHAN_WEAPON, "weapon_mossberg.fire");
		pl.w_attack_next = 0.5f;
		break;
	case AUTO_EMPTY:
		//Weapons_Sound(pl, CHAN_WEAPON, "weapon_mossberg.fire_empty");
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 1.5f;
}

void
w_sbs_reload(player pl)
{
	w_baseshotgun_reload(player::mag_sbs, player::m_iAmmoShells, 8);
}

void
w_sbs_release(player pl)
{
	int s = w_baseshotgun_release(player::mag_sbs, player::m_iAmmoShells, 8);

	switch (s) {
	case SHOTGUN_IDLE:
		int r = (float)input_sequence % 3;
		if (r == 1) {
			Weapons_ViewAnimation(pl, SBS_IDLE1);
		} else if (r == 2) {
			Weapons_ViewAnimation(pl, SBS_IDLE2);
		} else {
			Weapons_ViewAnimation(pl, SBS_IDLE3);
		}
		pl.w_idle_next = 5.0f;
		break;
	case SHOTGUN_BUSY:
		break;
	case SHOTGUN_START_RELOAD:
		Weapons_ViewAnimation(pl, SBS_START_RELOAD);
		break;
	case SHOTGUN_RELOAD:
		Weapons_ViewAnimation(pl, SBS_ADDSHELL);
		break;
	case SHOTGUN_END_RELOAD:
		Weapons_ViewAnimation(pl, SBS_PUMP);
		break;
	}
}

void
w_sbs_crosshair(player pl)
{
#ifdef CLIENT
	static vector cross_pos;
	cross_pos = (g_hudres / 2) + [-12,-12];
	drawsubpic(cross_pos, [24,24], "sprites/crosshairs.spr_0.tga", [48/128,24/128], [0.1875, 0.1875], [1,1,1], 1, DRAWFLAG_NORMAL);
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [72/256,72/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_sbs_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void
w_sbs_hudpic(player pl, int s, vector pos, float a)
{
#ifdef CLIENT
	if (s) {
		drawsubpic(pos, [170,45], "sprites/tfchud02.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/tfchud01.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_sbs =
{
	.name		= "sbs",
	.id		= ITEM_SBS,
	.slot		= 1,
	.slot_pos	= 0,
	.draw		= w_sbs_draw,
	.holster	= w_sbs_holster,
	.primary	= w_sbs_primary,
	.secondary	= w_sbs_release,
	.reload		= w_sbs_reload,
	.release	= w_sbs_release,
	.postdraw	= w_sbs_crosshair,
	.precache	= w_sbs_precache,
	.pickup		= w_sbs_pickup,
	.updateammo	= w_sbs_updateammo,
	.wmodel		= w_sbs_wmodel,
	.pmodel		= w_sbs_pmodel,
	.deathmsg	= w_sbs_deathmsg,
	.aimanim	= w_sbs_aimanim,
	.hudpic		= w_sbs_hudpic
};
