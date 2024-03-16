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

class info_player_teamspawn:NSSpawnPoint
{
	void(void) info_player_teamspawn;

	virtual void SpawnKey(string, string);

	nonvirtual void RenameTeamSpawns(void);
};

void
info_player_teamspawn::info_player_teamspawn(void)
{

}

void
info_player_teamspawn::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "team_no":
		team = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
info_player_teamspawn::RenameTeamSpawns(void)
{
	for (entity e = world; (e = find(e, ::classname, "info_player_teamspawn"));) {
		info_player_teamspawn findSpawn = (info_player_teamspawn)e;

		switch (findSpawn.team) {
		case 1:
			e.classname = "info_teamspawn_blue";
			break;
		case 2:
			e.classname = "info_teamspawn_red";
			break;
		case 3:
			e.classname = "info_teamspawn_yellow";
			break;
		case 4:
			e.classname = "info_teamspawn_green";
			break;
		}
	}

	botinfo = BOTINFO_SPAWNPOINT;
}

CLASSEXPORT(i_p_t, info_player_teamspawn)
