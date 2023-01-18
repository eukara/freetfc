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

#define TFC_RPG_ROCKET_SPEED 900.0f

enum
{
	INC_IDLE1,
	INC_FIDGET1,
	INC_FIRE,
	INC_HOLSTER1,
	INC_DRAW1,
	INC_HOLSTER2,
	INC_DRAW2,
	INC_RELOAD_START,
	INC_RELOAD,
	INC_RELOAD_END,
	INC_IDLE2,
	INC_FIDGET2
};

void
w_incendiary_precache(void)
{
	precache_model("models/v_tfc_rpg.mdl");
	precache_model("models/w_incendiary.mdl");
	precache_model("models/p_incendiary.mdl");
	Sound_Precache("weapon_incendiary.fire");
}

void
w_incendiary_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoRockets, __NULL__);
}

string
w_incendiary_wmodel(void)
{
	return "models/w_incendiary.mdl";
}
string
w_incendiary_pmodel(player pl)
{
	return "models/p_incendiary.mdl";
}

string
w_incendiary_deathmsg(void)
{
	return "%s gets well done by %s's incendiary rocket.";

	// TODO
	// Has special birthday and suicide death messages
}

void
w_incendiary_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_rpg.mdl");
	Weapons_ViewAnimation(pl, 0);
}

void
w_incendiary_shootrocket(player pl)
{
	static void w_incendiary_shootrocket_touch(void) {
		FX_Explosion(self.origin);
		remove(self);
	}

	Weapons_MakeVectors(pl);
	entity p = spawn();
	setmodel(p, "models/rpgrocket.mdl");
	setorigin(p, Weapons_GetCameraPos(pl) + (v_forward * 8));
	p.owner = self;
	p.movetype = MOVETYPE_FLYMISSILE;
	p.solid = SOLID_BBOX;
	p.gravity = 0.5f;
	p.velocity = (v_forward * TFC_RPG_ROCKET_SPEED);
	p.angles = vectoangles(p.velocity);
	p.touch = w_incendiary_shootrocket_touch;
	p.think = Util_Destroy;
	p.nextthink = time + 5.0f;
}

void
w_incendiary_primary(player pl)
{
	int s = w_baseprojectile_fire(pl, WEAPON_INCENDIARY, player::m_iAmmoRockets, w_incendiary_shootrocket);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
		Weapons_ViewAnimation(pl, INC_FIRE);
		Weapons_Sound(pl, CHAN_WEAPON, "weapon_incendiary.fire");
		Weapons_ViewPunchAngle(pl, [-2,0,0]);
		pl.w_attack_next = 0.8f;
		break;
	case AUTO_LAST:
		Weapons_ViewAnimation(pl, INC_FIRE);
		Weapons_Sound(pl, CHAN_WEAPON, "weapon_incendiary.fire");
		Weapons_ViewPunchAngle(pl, [-2,0,0]);
		pl.w_attack_next = 0.8f;
		break;
	case AUTO_EMPTY:
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 1.5f;
}

float
w_incendiary_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_incendiary_postdraw(player pl)
{
#ifdef CLIENT
	// crosshair
	Cross_DrawSub(g_cross_spr, [24,24], [24/128,48/128], [0.1875, 0.1875]);
	// ammo counter
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [120/256,72/128],[24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_incendiary_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud06.spr_0.tga",
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_incendiary =
{
	.name		= "incendiary",
	.id		= ITEM_INCENDIARY,
	.slot		= 4,
	.slot_pos	= 3,
	.draw		= w_incendiary_draw,
	.holster	= __NULL__,
	.primary	= w_incendiary_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.postdraw	= w_incendiary_postdraw,
	.precache	= w_incendiary_precache,
	.pickup		= __NULL__,
	.updateammo	= w_incendiary_updateammo,
	.wmodel		= w_incendiary_wmodel,
	.pmodel		= w_incendiary_pmodel,
	.deathmsg	= w_incendiary_deathmsg,
	.aimanim	= w_incendiary_aimanim,
	.hudpic		= w_incendiary_hudpic,
	.isempty	= w_asscan_isempty
};
