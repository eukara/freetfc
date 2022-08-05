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

void
Game_InitRules(void)
{
	g_grMode = spawn(TFCGameRules);
}

void
Game_Worldspawn(void)
{
	forceinfokey(world, "areadefs", "0");
	Sound_Precache("turret_tfc.idle_noise");
	Sound_Precache("turret_tfc.target_spotted");
	Sound_Precache("ammo.pickup");
	Sound_Precache("ammo.respawn");
	Sound_Precache("player.fall");
	Sound_Precache("player.lightfall");
	Sound_Precache("player_tfc.death");
	Sound_Precache("player_tfc.jump");
	Sound_Precache("engineer.build");
	Sound_Precache("engineer.turret_set");

	precache_model("models/base.mdl");
	precache_model("models/dispenser.mdl");
	precache_model("models/sentry1.mdl");
	precache_model("models/sentry2.mdl");
	precache_model("models/sentry3.mdl");
	precache_model("models/player.mdl");
	precache_model("models/w_weaponbox.mdl");
	Weapons_Init();
	Player_Precache();
	FX_Corpse_Init();
}

void weaponbox_spawn(player pl)
{
}

void
CSEv_TFCBuild_i(int type)
{
	player pl = (player)self;

	if (pl.gflags & GF_NOBUILDZONE) {
		env_message_single(pl, "#Build_nobuild");
		return;
	}

	switch (type) {
	case 1:
		TFCDispenser_Build();
		break;
	case 2:
		TFCSentry_Build();
		break;
	case 4:
		TFCTeleporter_Build();
		break;
	case 5:
		TFCTeleporterExit_Build();
		break;
	}
}

void
CSEv_TFCDismantle_i(int type)
{
	switch (type) {
	case 1:
		TFCDispenser_Dismantle();
		break;
	case 2:
		TFCSentry_Dismantle();
		break;
	case 4:
		TFCTeleporter_Dismantle();
		break;
	case 5:
		TFCTeleporterExit_Dismantle();
		break;
	}
}
