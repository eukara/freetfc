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

var int autocvar_sv_playerkeepalive = TRUE;

/* we check what fields have changed over the course of the frame and network
 * only the ones that have actually changed */
void
TFCGameRules::PlayerPostFrame(base_player pp)
{
}

void
TFCGameRules::LevelNewParms(void)
{
	parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
	parm8 = parm9 = parm10 = parm11 = parm12 = parm13 = parm14 =
	parm15 = parm16 = parm17 = parm18 = parm19 = parm20 = parm21 =
	parm22 = parm23 = parm24 = parm25 = parm26 = parm27 = parm28 =
	parm29 = parm30 = 0;
	parm64 = FL_CLIENT;
}

void
TFCGameRules::PlayerConnect(base_player pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s connected\n", pl.netname));
}

void
TFCGameRules::PlayerDisconnect(base_player pl)
{
	bprint(PRINT_HIGH, sprintf("%s disconnected\n", pl.netname));

	/* Make this unusable */
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NONE;
	pl.modelindex = 0;
	pl.health = 0;
	pl.takedamage = 0;
	pl.SendFlags = PLAYER_MODELINDEX;
}

void
TFCGameRules::PlayerKill(base_player pp)
{
	player pl = (player)pp;
	Damage_Apply(pl, pl, pl.health, WEAPON_NONE, DMG_SKIP_ARMOR);
}

void
TFCGameRules::PlayerSpawn(base_player pp)
{
	player pl = (player)pp;
	pl.classname = "unspawned";
	pl.health = 0;
	pl.armor = 0;
	pl.takedamage = DAMAGE_NO;
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NOCLIP;
//	pl.SendEntity = Player_SendEntity;
	pl.flags = FL_CLIENT;
	pl.weapon = 0;
	pl.viewzoom = 1.0f;
	pl.model = 0;
	setsize (pl, [-16,-16,-16], [16,16,16]);
	pl.view_ofs = pl.velocity = [0,0,0];
	forceinfokey(pl, "*spec", "2");
	Spawn_ObserverCam(pl);
}

void
TFCGameRules::TFCGameRules(void)
{
	forceinfokey(world, "teams", "2");
	forceinfokey(world, "team_1", "Blue");
	forceinfokey(world, "teamscore_1", "0");
	forceinfokey(world, "team_2", "Red");
	forceinfokey(world, "teamscore_2", "0");
}
