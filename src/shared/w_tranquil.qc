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
	TRANQUIL_IDLE1,
	TRANQUIL_IDLE2,
	TRANQUIL_IDLE3,
	TRANQUIL_SHOOT,
	TRANQUIL_SHOOT_EMPTY,
	TRANQUIL_RELOAD_EMPTY,
	TRANQUIL_RELOAD,
	TRANQUIL_DRAW,
	TRANQUIL_HOLSTER
};

void
w_tranquil_precache(void)
{
	precache_model("models/v_tfc_pistol.mdl");
	precache_model("models/w_tranquil.mdl");
	precache_model("models/p_tranquil.mdl");
}

void
w_tranquil_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, __NULL__, pl.m_iAmmoShells, __NULL__);
}

string
w_tranquil_wmodel(void)
{
	return "models/w_tranquil.mdl";
}
string
w_tranquil_pmodel(player pl)
{
	return "models/p_tranquil.mdl";
}

string
w_tranquil_deathmsg(void)
{
	return "%s is put to sleep by %s.";
}

void
w_tranquil_draw(player pl)
{
	Weapons_SetModel("models/v_tfc_pistol.mdl");
	Weapons_ViewAnimation(pl, TRANQUIL_DRAW);
	Weapons_SetGeomset("geomset 2 2\n");
}

void
w_tranquil_shootdart(player pl)
{
	static void w_rpg_shootrocket_touch(void) {
		#ifndef CLIENT
		/* impact per bullet */
		if (trace_ent.iBleeds == 0) {
			DecalGroups_Place("Impact.BigShot", trace_endpos + (v_forward * -2));
			SurfData_Impact(trace_ent, trace_surfaceflagsi, trace_endpos, trace_plane_normal);
		}
		#endif
		remove(self);
	}

	Weapons_MakeVectors(pl);
	entity p = spawn();
	setmodel(p, "models/nail.mdl");
	setorigin(p, Weapons_GetCameraPos(pl) + (v_forward * 14) + (v_up * -4) + (v_right * 2));
	p.owner = self;
	p.movetype = MOVETYPE_FLYMISSILE;
	p.solid = SOLID_BBOX;
	p.gravity = 0.5f;
	p.velocity = (v_forward * 1000) + (v_up * 4) + (v_right * -2);
	p.angles = vectoangles(p.velocity);
	p.touch = w_rpg_shootrocket_touch;
	p.think = Util_Destroy;
	p.nextthink = time + 5.0f;
}

void
w_tranquil_primary(player pl)
{
	int s = w_baseprojectile_fire(pl, WEAPON_TRANQUIL, player::m_iAmmoShells, w_tranquil_shootdart);

	switch (s) {
	case AUTO_FIRE_FAILED:
		return;
		break;
	case AUTO_FIRED:
	case AUTO_LAST:
		Weapons_ViewAnimation(pl, TRANQUIL_SHOOT);
		Weapons_ViewPunchAngle(pl, [-2,0,0]);
		#ifndef CLIENT
		Sound_Play(pl, CHAN_WEAPON, "weapon_tranquilizer.fire");
		#endif
		pl.w_attack_next = 1.5f;
		break;
	case AUTO_EMPTY:
		pl.w_attack_next = 0.2f;
		break;
	}

	pl.w_idle_next = 2.5f;
}

float
w_tranquil_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_tranquil_hud(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	Cross_DrawSub(g_cross_spr, [24,24], [0.1875,0], [0.1875, 0.1875]);

	HUD_DrawAmmo2();


	drawsubpic(aicon_pos, [24,24], g_hud7_spr, [72/256,72/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

void
w_tranquil_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud05.spr_0.tga",
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
			"sprites/tfchud06.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_tranquil =
{
	.name		= "tranquil",
	.id		= ITEM_TRANQUIL,
	.slot		= 1,
	.slot_pos	= 2,
	.draw		= w_tranquil_draw,
	.holster	= __NULL__,
	.primary	= w_tranquil_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= __NULL__,
	.postdraw	= w_tranquil_hud,
	.precache	= w_tranquil_precache,
	.pickup		= __NULL__,
	.updateammo	= w_tranquil_updateammo,
	.wmodel		= w_tranquil_wmodel,
	.pmodel		= w_tranquil_pmodel,
	.deathmsg	= w_tranquil_deathmsg,
	.aimanim	= w_tranquil_aimanim,
	.hudpic		= w_tranquil_hudpic,
	.isempty	= w_asscan_isempty
};
