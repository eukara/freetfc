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
CSEv_TeamJoin_f(float f)
{
	player pl = (player)self;

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
		/* invalid */
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
