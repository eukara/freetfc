

#define AMMO_COUNT 4

string g_ammo_spr;

typedef struct
{
	float alpha;
	int count;
} ammonote_t;
ammonote_t g_ammonotify[AMMO_COUNT];

vector g_ammotype[AMMO_COUNT] = {
	[120/256, 72/128], // rockets (valve's rocket)
	[0/256, 72/128], // nails (valve's pistol)
	[0/256, 96/128], // cells (valve's uranium)
	[72/256, 72/128], // shells
};

void
HUD_AmmoNotify_Init(void)
{
	g_ammo_spr = spriteframe("sprites/640hud7.spr", 0, 0.0f);
}

void
HUD_AmmoNotify_Draw(vector startpos)
{
	vector pos = startpos;

	for (int i = 0; i < AMMO_COUNT; i++) {
		vector srcpos;
		float a;

		/* make sure we skip any faded entries, and also null them */
		if (g_ammonotify[i].alpha <= 0.0f) {
			g_ammonotify[i].count = 0;
			continue;
		}

		/* let's get the src img pos for our type */
		srcpos = g_ammotype[i];
		a = bound(0, g_ammonotify[i].alpha, 1.0);

		drawsubpic(pos,
			[24,24],
			g_ammo_spr,
			srcpos,
			[24/256, 24/128],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);

		drawfont = Font_GetID(FONT_20);
		string txt = sprintf("%i", g_ammonotify[i].count);
		float offs = stringwidth(txt, FALSE, [20,20]);
		drawstring(pos + [-offs - 8,4], sprintf("%i", g_ammonotify[i].count), [20,20], g_hud_color, a, DRAWFLAG_ADDITIVE);

		g_ammonotify[i].alpha -= (clframetime * 0.5);
		pos -= [0, 32]; /* go up a notch */
	}
}

void
HUD_AmmoNotify_Insert(int type, int count)
{
	if (count <= 0)
		return;

	g_ammonotify[type].count += count;
	g_ammonotify[type].alpha = 2.5f;

}

/* called whenever we should check for pickup updates */
void
HUD_AmmoNotify_Check(player pl)
{
	HUD_AmmoNotify_Insert(0, pl.m_iAmmoRockets - pl.m_iAmmoRockets_net);
	HUD_AmmoNotify_Insert(1, pl.m_iAmmoNails - pl.m_iAmmoNails_net);
	HUD_AmmoNotify_Insert(2, pl.m_iAmmoCells - pl.m_iAmmoCells_net);
	HUD_AmmoNotify_Insert(3, pl.m_iAmmoShells - pl.m_iAmmoShells_net);
}