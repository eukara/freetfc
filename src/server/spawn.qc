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

float
TFCTeamJoin_SmallestTeam(int blue, int red, int yellow, int green)
{
	while (blue > 0i || red > 0i || yellow > 0i || green > 0i) {
		/* the first team that goes to 0, gets picked. */
		if (blue <= 0i)
			return 1;
		else if (red <= 0i)
			return 2;
		else if (yellow <= 0i)
			return 3;
		else if (green <= 0i)
			return 4;

		blue--;
		red--;
		yellow--;
		green--;
	}

	/* the first team that goes to 0, gets picked. */
	if (blue == 0i)
		return 1;
	else if (red == 0i)
		return 2;
	else if (yellow == 0i)
		return 3;
	else if (green == 0i)
		return 4;

	return 0;
}

void
CSEv_TeamJoin_f(float f)
{
	player pl = (player)self;

	/* random... */
	if (f == 0) {
		int bluePlayers = 0i;
		int redPlayers = 0i;
		int yellowPlayers = 0i;
		int greenPlayers = 0i;

		/* hack to get it to never pick this team */
		if (g_tfcHasBlueTeam == false)
			bluePlayers = (int)cvar("sv_playerslots");
		if (g_tfcHasRedTeam == false)
			redPlayers = (int)cvar("sv_playerslots");
		if (g_tfcHasYellowTeam == false)
			yellowPlayers = (int)cvar("sv_playerslots");
		if (g_tfcHasGreenTeam == false)
			greenPlayers = (int)cvar("sv_playerslots");

		/* count all valid players within each team */
		for (entity e = world; (e = find(e, ::classname, "player"));) {
			if (e.team == 1)
				bluePlayers++;
			else if (e.team == 2)
				redPlayers++;
			else if (e.team == 3)
				yellowPlayers++;
			else if (e.team == 4)
				greenPlayers++;
		}

		/* assign us to the team with the lowest amount of players */
		f = TFCTeamJoin_SmallestTeam(bluePlayers, redPlayers, yellowPlayers, greenPlayers);
	}

	/* mess, do it better */
	if (f == 1) {
		pl.team = 1; /* Blue */
		forceinfokey(pl, "topcolor", "0x9aff");
		forceinfokey(pl, "bottomcolor", "0x9aff");
	} else if (f == 2) {
		pl.team = 2; /* Red */
		f -= 10;
		forceinfokey(pl, "topcolor", "0xff1800");
		forceinfokey(pl, "bottomcolor", "0xff1800");
	} else if (f == 3) {
		pl.team = 3; /* Yellow */
		f -= 20;
		forceinfokey(pl, "topcolor", "0xffca00");
		forceinfokey(pl, "bottomcolor", "0xffca00");
	} else if (f == 4) {
		pl.team = 4; /* Green */
		f -= 30;
		forceinfokey(pl, "topcolor", "0x3bff00");
		forceinfokey(pl, "bottomcolor", "0x3bff00");
	} else {
		return;
	}

	if (self.health > 0) {
		ClientKill();
		return;
	}
} 

/** Called by the client-side VGUI menu when we choose a class. */
void
CSEv_ClassJoin_f(float f)
{

	player pl = (player)self;

	/* choose a random class. */
	if (f == 0) {
		float newClass = 0;

		while (newClass == 0 || newClass == pl.classtype)
			newClass = floor(random(CLASS_SCOUT, CLASS_ENGINEER + 1));

		f = newClass;
	}

	/* invalid */
	if (pl.team == 0) {
		return;
	}

	if (self.classname != "player") {
		spawnfunc_player();
	}

	/* invalid */
	if (pl.classtype == f)
		return;

	/* if we're still alive... */
	if (pl.health > 0) {
		pl.classtype = f;
		pl.MakeClass(f);
		ClientKill();
	} else {
		/* insta spawn */

		/* assign our class type for safe keeping */
		pl.classtype = f;

		/* turn the player into the class of his choice */
		pl.MakeClass(f);
		pl.SpawnIntoGame();
	}
} 
