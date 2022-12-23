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

bool
TFCGameRules::IsTeamplay(void)
{
	return TRUE;
}

void
TFCGameRules::DropGoalItem(NSClientPlayer pp)
{
	/* skip normal players */
	if (!(pp.g_items & ITEM_GOALITEM))
		return;

	item_tfgoal target;

	for (entity e = world; (e = find(e, ::classname, "item_tfgoal"));) {
		target = (item_tfgoal)e;

		/* item is still pick-upable */
		if (target.solid != SOLID_NOT) {
			print("the item is not picked up. \n");
			continue;
		}

		/* that's us, yup */
		if (target.m_eActivator == pp) {
			target.DropReturnable(pp);
			return;
		}
	}

	print("^1WARNING: ^7Player marked as having impossible goal-item\n");
}

/* we check what fields have changed over the course of the frame and network
 * only the ones that have actually changed */
void
TFCGameRules::PlayerPostFrame(NSClientPlayer pp)
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
TFCGameRules::PlayerConnect(NSClientPlayer pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s connected\n", pl.netname));
}

void
TFCGameRules::PlayerDisconnect(NSClientPlayer pl)
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
TFCGameRules_PlayerRespawn(void)
{
	TFCGameRules rule = (TFCGameRules)g_grMode;
	rule.PlayerRespawn((NSClientPlayer)self);
}

void
TFCGameRules::PlayerDeath(NSClientPlayer pp)
{
	player pl = (player)pp;

	DropGoalItem(pp);
	pl.SetSolid(SOLID_NOT);
	pl.SetMovetype(MOVETYPE_NONE);

	pl.ScheduleThink(TFCGameRules_PlayerRespawn, 4.0f);

	/* play the iconic death sound */
	Sound_Play(pl, CHAN_VOICE, "player_tfc.death");
}

void
TFCGameRules::PlayerKill(NSClientPlayer pp)
{
	player pl = (player)pp;
	Damage_Apply(pl, pl, pl.health, WEAPON_NONE, DMG_SKIP_ARMOR);
}

void
TFCGameRules::PlayerRespawn(NSClientPlayer pp)
{
	player pl = (player)pp;
	pl.MakeClass(pl.classtype);
	pl.SpawnIntoGame();
}

void
TFCGameRules::PlayerSpawn(NSClientPlayer pp)
{
	player pl = (player)pp;
	pl.MakeTempSpectator(); /* replace this with a non-spectator ghost */
	Spawn_ObserverCam(pl);
}

void
TFCGameRules::TFCGameRules(void)
{
	/* TODO: Make this depend on the actual spawn types */
	forceinfokey(world, "teams", "2");
	forceinfokey(world, "team_1", "Blue");
	forceinfokey(world, "teamscore_1", "0");
	forceinfokey(world, "team_2", "Red");
	forceinfokey(world, "teamscore_2", "0");
}
