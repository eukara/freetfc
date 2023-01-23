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

static CUIWindow winClassSelection;

typedef struct
{
	string str;
	void(void) ptr;
} btnarr_t;

void
VGUI_ClassJoin(float i)
{
	sendevent("ClassJoin", "f", i);
	winClassSelection.Hide();
}

void
VGUI_TeamBack(void)
{
	
}

void VGUI_JoinScout (void) { VGUI_ClassJoin(1); }
void VGUI_JoinSniper (void) { VGUI_ClassJoin(2); }
void VGUI_JoinSoldier (void) { VGUI_ClassJoin(3); }
void VGUI_JoinDemoman (void) { VGUI_ClassJoin(4); }
void VGUI_JoinMedic (void) { VGUI_ClassJoin(5); }
void VGUI_JoinHwguy (void) { VGUI_ClassJoin(6); }
void VGUI_JoinPyro (void) { VGUI_ClassJoin(7); }
void VGUI_JoinSpy (void) { VGUI_ClassJoin(8); }
void VGUI_JoinEngineer (void) { VGUI_ClassJoin(9); }

btnarr_t g_tfc_vgui_classlist[] = {
	{"SCOUT", VGUI_JoinScout },
	{"SNIPER", VGUI_JoinSniper },
	{"SOLDIER", VGUI_JoinSoldier },
	{"DEMOMAN", VGUI_JoinDemoman },
	{"MEDIC", VGUI_JoinMedic },
	{"HWGUY", VGUI_JoinHwguy },
	{"PYRO", VGUI_JoinPyro },
	{"SPY", VGUI_JoinSpy },
	{"ENGINEER", VGUI_JoinEngineer },
	{__NULL__, __NULL__ },
	{"< Back", VGUI_TeamBack }
};

void
VGUI_ChooseClass(void)
{
	static int initialized;
	static CUIButton *btns;

	if (!initialized) {
		vector btnpos = [16,0];
		initialized = TRUE;
		winClassSelection = spawn(CUIWindow);
		winClassSelection.SetTitle("Choose Skin");
		winClassSelection.SetSize([420,320]);
		g_uiDesktop.Add(winClassSelection);

		btns = memalloc(sizeof(btnarr_t) * g_tfc_vgui_classlist.length);
		for (int i = 0; i < g_tfc_vgui_classlist.length; i++) {
			btnpos[1] += 30;
			if (g_tfc_vgui_classlist[i].ptr == __NULL__) {
				continue;
			}
			btns[i] = spawn(CUIButton);
			btns[i].SetTitle(g_tfc_vgui_classlist[i].str);
			btns[i].SetPos(btnpos);
			btns[i].SetFunc(g_tfc_vgui_classlist[i].ptr);
			winClassSelection.Add(btns[i]);
		}
	}

	winClassSelection.Show();
	winClassSelection.SetPos((video_res / 2) - (winClassSelection.GetSize() / 2));
}