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

class
TFCVox:NSTalkMonster
{
	void(void) TFCVox;
	virtual void(string) SentenceSample;
};

TFCVox g_vox;

void
TFCVox::SentenceSample(string sample)
{
	sound(this, CHAN_VOICE, sample, 1.0, ATTN_NONE, 100, SOUNDFLAG_FOLLOW | SOUNDFLAG_NOSPACIALISE);
}

void
TFCVox::TFCVox(void)
{
}

void
Vox_Parse(void)
{
	string msg = readstring();

	if (!g_vox)
		g_vox = spawn(TFCVox);

	print(msg);
	print("\n");
	g_vox.Sentence(msg);
} 
