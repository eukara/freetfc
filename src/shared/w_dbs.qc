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
	DBS_IDLE1,
	DBS_FIRE1,
	DBS_FIRE2,
	DBS_ADDSHELL,
	DBS_PUMP,
	DBS_START_RELOAD,
	DBS_DRAW,
	DBS_HOLSTER,
	DBS_IDLE2,
	DBS_IDLE3
};

void
w_dbs_precache(void)
{
	precache_model("models/v_tfc_shotgun.mdl");
	precache_model("models/w_shot2.mdl");
	precache_model("models/p_shot2.mdl");
	precache_sound("weapons/sbarrel1.wav");
	precache_sound("weapons/dbarrel1.wav");
	precache_sound("weapons/reload3.wav");
	precache_sound("weapons/scock1.wav");
}

void
w_dbs_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mag_dbs, pl.m_iAmmoShells, __NULL__);
}

string
w_dbs_wmodel(void)
{
	return "models/w_shot2.mdl";
}

string
w_dbs_pmodel(void)
{
	return "models/p_shot2.mdl";
}

string
w_dbs_deathmsg(void)
{
	return "";
}

int
w_dbs_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;
	pl.mag_dbs = bound(0, pl.mag_dbs + 16, 16);
#endif
	return (1);
}

void
w_dbs_draw(void)
{
	Weapons_SetModel("models/v_tfc_shotgun.mdl");
	Weapons_ViewAnimation(DBS_DRAW);
}

void
w_dbs_holster(void)
{
	Weapons_ViewAnimation(DBS_HOLSTER);
}

void
w_dbs_primary(void)
{
	int s;
	player pl = (player)self;

	if (pl.mag_dbs != 1)
		s = w_baseshotgun_fire(WEAPON_DBS, player::mag_dbs, 14, 4, [0.14, 0.08, 0]);
	else
		s = w_baseshotgun_fire(WEAPON_DBS, player::mag_dbs, 6, 4, [0.14, 0.08, 0]);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
		pl.mag_dbs--;
		Weapons_ViewAnimation(DBS_FIRE1);
		Weapons_ViewPunchAngle([-2,0,0]);
		//Weapons_Sound(pl, CHAN_WEAPON, "weapon_mossberg.fire");
		pl.w_attack_next = 0.7f;
		break;
	case AUTO_LAST:
		Weapons_ViewAnimation(DBS_FIRE1);
		Weapons_ViewPunchAngle([-2,0,0]);
		//Weapons_Sound(pl, CHAN_WEAPON, "weapon_mossberg.fire");
		pl.w_attack_next = 0.7f;
		break;
	case AUTO_EMPTY:
		//Weapons_Sound(pl, CHAN_WEAPON, "weapon_mossberg.fire_empty");
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 1.5f;
}

void
w_dbs_reload(void)
{
	player pl = (player)self;
	w_baseshotgun_reload(player::mag_dbs, player::m_iAmmoShells, 16);
}

void
w_dbs_release(void)
{
	player pl = (player)self;
	int s = w_baseshotgun_release(player::mag_dbs, player::m_iAmmoShells, 16);

	switch (s) {
	case SHOTGUN_IDLE:
		int r = (float)input_sequence % 3;
		if (r == 1) {
			Weapons_ViewAnimation(DBS_IDLE1);
		} else if (r == 2) {
			Weapons_ViewAnimation(DBS_IDLE2);
		} else {
			Weapons_ViewAnimation(DBS_IDLE3);
		}
		pl.w_idle_next = 5.0f;
		break;
	case SHOTGUN_BUSY:
		break;
	case SHOTGUN_START_RELOAD:
		Weapons_ViewAnimation(DBS_START_RELOAD);
		break;
	case SHOTGUN_RELOAD:
		Weapons_ViewAnimation(DBS_ADDSHELL);
		break;
	case SHOTGUN_END_RELOAD:
		Weapons_ViewAnimation(DBS_PUMP);
		break;
	}
}

void
w_dbs_crosshair(void)
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
w_dbs_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSHOTGUN : ANIM_AIMSHOTGUN;
}

void
w_dbs_hudpic(int s, vector pos, float a)
{
#ifdef CLIENT
	if (s) {
		drawsubpic(pos, [170,45], "sprites/640hud4.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud1.spr_0.tga", [0,180/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_dbs =
{
	.name		= "sbs",
	.id		= ITEM_DBS,
	.slot		= 2,
	.slot_pos	= 1,
	.draw		= w_dbs_draw,
	.holster	= w_dbs_holster,
	.primary	= w_dbs_primary,
	.secondary	= w_dbs_release,
	.reload		= w_dbs_reload,
	.release	= w_dbs_release,
	.crosshair	= w_dbs_crosshair,
	.precache	= w_dbs_precache,
	.pickup		= w_dbs_pickup,
	.updateammo	= w_dbs_updateammo,
	.wmodel		= w_dbs_wmodel,
	.pmodel		= w_dbs_pmodel,
	.deathmsg	= w_dbs_deathmsg,
	.aimanim	= w_dbs_aimanim,
	.hudpic		= w_dbs_hudpic
};
