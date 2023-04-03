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

static string g_classDescrScout;
static string g_classDescrSniper;
static string g_classDescrSoldier;
static string g_classDescrDemoman;
static string g_classDescrMedic;
static string g_classDescrHWGuy;
static string g_classDescrPyro;
static string g_classDescrSpy;
static string g_classDescrEngineer;
static string g_classDescrRandomPC;

static void
TFCClass_Init(void)
{
	g_classDescrScout = textfile_to_string("classes/short_scout.txt");
	g_classDescrSniper = textfile_to_string("classes/short_sniper.txt");
	g_classDescrSoldier = textfile_to_string("classes/short_soldier.txt");
	g_classDescrDemoman = textfile_to_string("classes/short_demoman.txt");
	g_classDescrMedic = textfile_to_string("classes/short_medic.txt");
	g_classDescrHWGuy = textfile_to_string("classes/short_hwguy.txt");
	g_classDescrPyro = textfile_to_string("classes/short_pyro.txt");
	g_classDescrSpy = textfile_to_string("classes/short_spy.txt");
	g_classDescrEngineer = textfile_to_string("classes/short_engineer.txt");
	g_classDescrRandomPC = textfile_to_string("classes/short_randompc.txt");
}

static VGUIWindow winClassSelection;
static VGUIPic imgClassPreview;
static VGUILabel lblClassTitle;
static VGUILabel lblClassDescription;
static VGUILabel lblClassCounter;

class TFClassButton:VGUIButton
{
	void TFClassButton(void);

	virtual void OnMouseUp(void);
	virtual void OnMouseEntered(void);
};

void
TFClassButton::TFClassButton(void)
{
}

void
TFClassButton::OnMouseUp(void)
{
	int classSelection = GetTag();
	sendevent("ClassJoin", "f", (float)classSelection);
	winClassSelection.Hide();
}

void
TFClassButton::OnMouseEntered(void)
{
	int classSelection = GetTag();
	string teamName = "blue";

	switch (getplayerkeyfloat(player_localnum, "*team")) {
	case 1:
		teamName = "blue";
		break;
	case 2:
		teamName = "red";
		break;
	case 3:
		teamName = "blue";	/* TFC doesn't ship with a real green. */
		break;
	case 4:
		teamName = "red";	/* TFC doesn't ship with a real yellow either. */
		break;
	}

	switch (classSelection) {
		case 1:
			lblClassTitle.SetTitle("Scout");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_scout", teamName));
			lblClassDescription.SetTitle(g_classDescrScout);
			break;
		case 2:
			lblClassTitle.SetTitle("Sniper");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_sniper", teamName));
			lblClassDescription.SetTitle(g_classDescrSniper);
			break;
		case 3:
			lblClassTitle.SetTitle("Soldier");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_soldier", teamName));
			lblClassDescription.SetTitle(g_classDescrSoldier);
			break;
		case 4:
			lblClassTitle.SetTitle("Demoman");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_demoman", teamName));
			lblClassDescription.SetTitle(g_classDescrDemoman);
			break;
		case 5:
			lblClassTitle.SetTitle("Medic");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_medic", teamName));
			lblClassDescription.SetTitle(g_classDescrMedic);
			break;
		case 6:
			lblClassTitle.SetTitle("Heavy Weapons Guy");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_hwguy", teamName));
			lblClassDescription.SetTitle(g_classDescrHWGuy);
			break;
		case 7:
			lblClassTitle.SetTitle("Pyro");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_pyro", teamName));
			lblClassDescription.SetTitle(g_classDescrPyro);
			break;
		case 8:
			lblClassTitle.SetTitle("Spy");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_spy", teamName));
			lblClassDescription.SetTitle(g_classDescrSpy);
			break;
		case 9:
			lblClassTitle.SetTitle("Engineer");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_engineer", teamName));
			lblClassDescription.SetTitle(g_classDescrEngineer);
			break;
		case 0:
			lblClassTitle.SetTitle("Random");
			imgClassPreview.SetImage(strcat("gfx/vgui/640_randompc", teamName));
			lblClassDescription.SetTitle(g_classDescrRandomPC);
			break;
	}
}

string g_classnames [] = {
	"SCOUT",
	"SNIPER",
	"SOLDIER",
	"DEMOMAN",
	"MEDIC",
	"HWGUY",
	"PYRO",
	"SPY",
	"ENGINEER",
	"RANDOM"
};

void
VGUI_ChooseClass(void)
{
	static int initialized;
	static TFClassButton *btns;
	static VGUILabel lblSelectClass;
	static VGUIFrame frmClassInfo;

	if (!initialized) {
		vector btnpos = [40,80];
		initialized = TRUE;

		TFCClass_Init();

		winClassSelection = spawn(VGUIWindow);
		winClassSelection.SetSize([640, 480]);
		winClassSelection.SetStyleMask(VGUIWindowBorderless | VGUIWindowFullscreen);

		lblSelectClass = spawn(VGUILabel);
		lblSelectClass.SetTitle("SELECT YOUR CLASS");
		lblSelectClass.SetTextSize(19);
		lblSelectClass.SetPos([40, 38]);
		lblSelectClass.SetSize([400, 24]);

		frmClassInfo = spawn(VGUIFrame);
		frmClassInfo.SetPos([176, 80]);
		frmClassInfo.SetSize([424, 312]);

		imgClassPreview = spawn(VGUIPic);
		imgClassPreview.SetPos([190, 90]);

		lblClassTitle = spawn(VGUILabel);
		lblClassTitle.SetPos([338, 90]);
		lblClassTitle.SetTextSize(19);
		lblClassTitle.SetSize([320, 24]);

		lblClassCounter = spawn(VGUILabel);
		lblClassCounter.SetPos([338, 90 + 32]);
		lblClassCounter.SetSize([320, 18]);

		lblClassDescription = spawn(VGUILabel);
		lblClassDescription.SetPos([338, 90 + 32 + 32]);
		lblClassDescription.SetSize([250, 240]);

		g_uiDesktop.Add(winClassSelection);
		winClassSelection.Add(lblSelectClass);
		winClassSelection.Add(frmClassInfo);
		winClassSelection.Add(imgClassPreview);
		winClassSelection.Add(lblClassTitle);
		winClassSelection.Add(lblClassCounter);
		winClassSelection.Add(lblClassDescription);

		btns = memalloc(sizeof(TFClassButton) * g_classnames.length);
		for (int i = 0; i < g_classnames.length; i++) {
			btns[i] = spawn(TFClassButton);
			btns[i].SetTitle(g_classnames[i]);
			btns[i].SetSize([124, 24]);
			btns[i].SetPos(btnpos);

			if (i == 9) {
				btns[i].SetKeyEquivalent("0");
				btns[i].SetTag(0);
			} else {
				btns[i].SetKeyEquivalent(ftos((float)i+1));
				btns[i].SetTag(i+1i);
			}

			winClassSelection.Add(btns[i]);
			btnpos[1] += 32;
		}
	}

	winClassSelection.Show();
	winClassSelection.SetPos((video_res / 2) - (winClassSelection.GetSize() / 2));
}