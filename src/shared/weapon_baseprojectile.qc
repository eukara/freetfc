/*
 * Copyright (c) 2016-2022 Vera Visions LLC.
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
	SEMI_FIRE_FAILED,
	SEMI_FIRED,
	SEMI_LAST,
	SEMI_EMPTY
};

int
w_baseprojectile_fire(player pl, int w, .int mag, void(player) spawnfunc)
{
	if (pl.w_attack_next > 0.0) {
		return (SEMI_FIRE_FAILED);
	}
	if (pl.gflags & GF_SEMI_TOGGLED) {
		return (SEMI_FIRE_FAILED);
	}
	if (pl.(mag) <= 0) {
		return (SEMI_EMPTY);
	}

	pl.(mag)--;

#ifdef SERVER
	spawnfunc(pl);
#endif

	if (pl.(mag) == 0)
		return (SEMI_LAST);
	else
		return (SEMI_FIRED);
}

int
w_baseprojectile_fire_num(player pl, int w, .int mag, void(player) spawnfunc, int num)
{
	if (pl.w_attack_next > 0.0) {
		return (SEMI_FIRE_FAILED);
	}
	if (pl.gflags & GF_SEMI_TOGGLED) {
		return (SEMI_FIRE_FAILED);
	}
	if ((pl.(mag) - num) < 0) {
		return (SEMI_EMPTY);
	}

	pl.(mag) -= num;

#ifdef SERVER
	spawnfunc(pl);
#endif

	if (pl.(mag) == 0)
		return (SEMI_LAST);
	else
		return (SEMI_FIRED);
}

