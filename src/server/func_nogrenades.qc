/*
 * Copyright (c) 2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED func_nogrenades (0 .5 .8) ?

TEAM FORTRESS (1996) ENTITY

Brush volume that when entered, will not allow you to deploy any grenades.

-------- KEYS --------
"targetname"    Name
*/

class
func_nogrenades:NSBrushTrigger
{
	void(void) func_nogrenades;

	virtual void(void) Respawn;
	virtual void(entity) Touch;
};

void
func_nogrenades::Touch(entity eToucher)
{
	player pl = (player)eToucher;
	if (!(eToucher.flags & FL_CLIENT))
		return;

	pl.gflags |= GF_NOGRENADEZONE;
}

void
func_nogrenades::Respawn(void)
{
	InitBrushTrigger();
}

void
func_nogrenades::func_nogrenades(void)
{

}