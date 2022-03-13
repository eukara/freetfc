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

#define TFC_RPG_ROCKET_SPEED 900.0f

enum
{
	RPG_IDLE1,
	RPG_FIDGET1,
	RPG_FIRE,
	RPG_HOLSTER1,
	RPG_DRAW1,
	RPG_HOLSTER2,
	RPG_DRAW2,
	RPG_RELOAD_START,
	RPG_RELOAD,
	RPG_RELOAD_END,
	RPG_IDLE2,
	RPG_FIDGET2
};

void
w_rpg_precache(void)
{
	precache_model("models/v_tfc_rpg.mdl");
	precache_model("models/w_rpg.mdl");
	precache_model("models/p_rpg.mdl");
	precache_model("models/rpgrocket.mdl");
}

int
w_rpg_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;
	pl.mag_rpg = bound(0, pl.mag_rpg + 4, 4);
#endif
	return (1);
}

void
w_rpg_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.mag_rpg, pl.m_iAmmoRockets, __NULL__);
}

string
w_rpg_wmodel(void)
{
	return "models/w_rpg.mdl";
}

string
w_rpg_pmodel(void)
{
	return "models/p_rpg.mdl";
}

string
w_rpg_deathmsg(void)
{
	return "%s was assaulted by %s's Assault Cannon.";
}

void
w_rpg_draw(void)
{
	Weapons_SetModel("models/v_tfc_rpg.mdl");
	Weapons_ViewAnimation(0);
}

void
w_rpg_shootrocket(void)
{
	static void w_rpg_shootrocket_touch(void) {
		FX_Explosion(self.origin);
		remove(self);
	}

	Weapons_MakeVectors();
	entity p = spawn();
	setmodel(p, "models/rpgrocket.mdl");
	setorigin(p, Weapons_GetCameraPos() + (v_forward * 8));
	p.owner = self;
	p.movetype = MOVETYPE_FLYMISSILE;
	p.solid = SOLID_BBOX;
	p.gravity = 0.5f;
	p.velocity = (v_forward * TFC_RPG_ROCKET_SPEED);
	p.angles = vectoangles(p.velocity);
	p.touch = w_rpg_shootrocket_touch;
	p.think = Util_Destroy;
	p.nextthink = time + 5.0f;
}

void
w_rpg_primary(void)
{
	player pl = (player)self;
	int s = w_baseprojectile_fire(WEAPON_RPG, player::mag_rpg, w_rpg_shootrocket);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
		Weapons_ViewAnimation(RPG_FIRE);
		Weapons_ViewPunchAngle([-2,0,0]);
		pl.w_attack_next = 0.8f;
		break;
	case AUTO_LAST:
		Weapons_ViewAnimation(RPG_FIRE);
		Weapons_ViewPunchAngle([-2,0,0]);
		pl.w_attack_next = 0.8f;
		break;
	case AUTO_EMPTY:
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 1.5f;
}

void
w_rpg_reload(void)
{
	player pl = (player)self;
	w_baseshotgun_reload(player::mag_rpg, player::m_iAmmoRockets, 4);
}

void
w_rpg_release(void)
{
	player pl = (player)self;
	int s = w_baseshotgun_release(player::mag_rpg, player::m_iAmmoRockets, 4);

	switch (s) {
	case SHOTGUN_IDLE:
		int r = (float)input_sequence % 3;
		if (r == 1) {
			Weapons_ViewAnimation(RPG_IDLE1);
		} else if (r == 2) {
			Weapons_ViewAnimation(RPG_FIDGET1);
		} else {
			Weapons_ViewAnimation(RPG_FIDGET2);
		}
		pl.w_idle_next = 5.0f;
		break;
	case SHOTGUN_BUSY:
		break;
	case SHOTGUN_START_RELOAD:
		Weapons_ViewAnimation(RPG_RELOAD_START);
		break;
	case SHOTGUN_RELOAD:
		Weapons_ViewAnimation(RPG_RELOAD);
		break;
	case SHOTGUN_END_RELOAD:
		Weapons_ViewAnimation(RPG_RELOAD_END);
		break;
	}
}

float
w_rpg_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_rpg_hud(void)
{
#ifdef CLIENT
	player pl = (player)self;
	vector cross_pos;
	vector aicon_pos;

	/* crosshair/laser */
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(
		cross_pos,
		[24,24],
		g_cross_spr,
		[0,0],
		[0.1875, 0.1875],
		[1,1,1],
		1,
		DRAWFLAG_NORMAL
	);

	/* ammo counters */
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[120/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}


void
w_rpg_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(pos, [170,45], "sprites/640hud5.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	} else {
		drawsubpic(pos, [170,45], "sprites/640hud2.spr_0.tga", [0,45/256], [170/256,45/256], g_hud_color, a, DRAWFLAG_ADDITIVE);
	}
#endif
}

weapon_t w_rpg =
{
	.name		= "rpg",
	.id		= ITEM_RPG,
	.slot		= 4,
	.slot_pos	= 0,
	.draw		= w_rpg_draw,
	.holster	= __NULL__,
	.primary	= w_rpg_primary,
	.secondary	= __NULL__,
	.reload		= w_rpg_reload,
	.release	= w_rpg_release,
	.crosshair	= w_rpg_hud,
	.precache	= w_rpg_precache,
	.pickup		= w_rpg_pickup,
	.updateammo	= w_rpg_updateammo,
	.wmodel		= w_rpg_wmodel,
	.pmodel		= w_rpg_pmodel,
	.deathmsg	= w_rpg_deathmsg,
	.aimanim	= w_rpg_aimanim,
	.hudpic		= w_rpg_hudpic
};
