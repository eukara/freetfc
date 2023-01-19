/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
 * Copyright (c) 2019-2020 Gethyn ThomasQuail <xylemon@posteo.net>
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
	EGON_IDLE1,
	EGON_FIDGET1,
	EGON_ALTFIREON,
	EGON_ALTFIRECYCLE,
	EGON_ALTFIREOFF,
	EGON_FIRE1,
	EGON_FIRE2,
	EGON_FIRE3,
	EGON_FIRE4,
	EGON_DRAW,
	EGON_HOLSTER
};

void
w_flamer_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_flame.fire");
	precache_model("sprites/fthrow.spr");
#endif
	precache_model("models/v_flame.mdl");
	precache_model("models/w_egon.mdl");
	precache_model("models/p_egon.mdl");
}

void
w_flamer_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.m_iAmmoCells, -1);
}

string
w_flamer_wmodel(void)
{
	return "models/w_egon.mdl";
}

string
w_flamer_pmodel(player pl)
{
	return "models/p_egon.mdl";
}

string
w_flamer_deathmsg(void)
{
	return "%s burned to a crisp by %s's Flamethrower.";
}

int
w_flamer_pickup(player pl, int new, int startammo)
{
	return (1);
}

void
w_flamer_draw(player pl)
{
	Weapons_SetModel("models/v_flame.mdl");
	Weapons_ViewAnimation(pl, EGON_DRAW);
}

void
w_flamer_holster(player pl)
{

}

void
w_flamer_primary(player pl)
{
	if (pl.w_attack_next > 0.0)
		return;

	/* Ammo check */
	if (pl.m_iAmmoCells <= 0)
		return;

	pl.m_iAmmoCells--;
	Weapons_ViewAnimation(pl, EGON_FIRE1);

#ifdef SERVER

	static void w_flamer_die(void) {
		NSEntity::Destroy();
	}

	static void w_flamer_touch(entity target, entity source) {
		NSEntity me = (NSEntity)source;

		if (target.takedamage == DAMAGE_YES) {
			NSSurfacePropEntity m = (NSSurfacePropEntity)target;
			m.Ignite(source, 5.0f, WEAPON_FLAMER);
		}
	}



	Sound_Play(pl, CHAN_WEAPON, "weapon_flame.fire");
	NSProjectile ball = spawn(NSProjectile);
	ball.SetModel("sprites/fthrow.spr");
	ball.SetRenderMode(RM_ADDITIVE);
	ball.SetOwner(pl);
	ball.SetImpact(w_flamer_touch);
	ball.AnimateOnce(0, 15, 0.1f);

// To be added to spec
//	ball.Animate(0,15);
//	ball.effects |= EF_BRIGHTLIGHT;

// Also will need check for water contents (so projectile will die underwater)

	Weapons_MakeVectors(pl);
	ball.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 16));
	ball.SetVelocity(v_forward * 300);
#endif

	pl.w_attack_next = 0.2f;
	pl.w_idle_next = 0.2f;
}

void
w_flamer_reload(player pl)
{
}

void
w_flamer_release(player pl)
{
	if (pl.w_attack_next > 0)
		return;

	if (pl.w_idle_next > 0)
		return;

	Weapons_ViewAnimation(pl, EGON_IDLE1);
}

void
w_flamer_crosshair(player pl)
{
#ifdef CLIENT
	Cross_DrawSub(g_cross_spr, [24,24], [48/128,24/128], [0.1875, 0.1875]);
	//Cross_DrawSub(g_cross_spr, [24,24], [72/128,48/128], [0.1875, 0.1875]);
	HUD_DrawAmmo2();
	vector aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(aicon_pos, [24,24], "sprites/640hud7.spr_0.tga", [0,96/128], [24/256, 24/128], g_hud_color, pSeatLocal->m_flAmmo2Alpha, DRAWFLAG_ADDITIVE);
#endif
}

float
w_flamer_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_flamer_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (pl.m_iAmmoCells == 0)
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.m_iAmmoCells, 200, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud04.spr_0.tga",
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/tfchud03.spr_0.tga",
			[0,0/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

int
w_flamer_isempty(player pl)
{

	if (pl.m_iAmmoCells <= 0)
		return 1;

	return 0;
}

weapontype_t
w_flamer_type(player pl)
{
	return WPNTYPE_RANGED;
}

weapon_t w_flamer =
{
	.name		= "flamer",
	.id			= ITEM_FLAMER,
	.slot		= 3,
	.slot_pos	= 2,
	.draw		= w_flamer_draw,
	.holster	= __NULL__,
	.primary	= w_flamer_primary,
	.secondary	= w_flamer_release,
	.reload		= __NULL__,
	.release	= w_flamer_release,
	.postdraw	= w_flamer_crosshair,
	.precache	= w_flamer_precache,
	.pickup		= w_flamer_pickup,
	.updateammo	= w_flamer_updateammo,
	.wmodel		= w_flamer_wmodel,
	.pmodel		= w_flamer_pmodel,
	.deathmsg	= w_flamer_deathmsg,
	.aimanim	= w_flamer_aimanim,
	.isempty	= w_flamer_isempty,
	.type		= w_flamer_type,
	.hudpic		= w_flamer_hudpic
};
