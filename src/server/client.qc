/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

/* called every input frame */
void
Game_RunClientCommand(void)
{
	player pl = (player)self;

	/* clear map triggers */
	pl.gflags &= ~GF_NOBUILDZONE;
	pl.gflags &= ~GF_NOGRENADEZONE;

	pl.Physics_Run();
}

/* client cmd overrides happen here */
void
Game_ParseClientCommand(string cmd)
{
	tokenize(cmd);

	if (argv(1) == "timeleft") {
		string msg;
		string timestring;
		float timeleft;
		timeleft = cvar("timelimit") - (time / 60);
		timestring = Util_TimeToString(timeleft);
		msg = sprintf("we have %s minutes remaining", timestring);
		bprint(PRINT_CHAT, msg);
		return;
	}

	clientcommand(self, cmd);
}
