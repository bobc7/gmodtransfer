-- Should background blur be enabled while the menu is open?
HT_MENU_BG_BLUR = true
-- What should the title of the menu be?
HT_MENU_TITLE = "Hedges Money Transfer Menu!"


-- MENU COLORS
if CLIENT then
    HT_MENU_COLOR = Color(35, 35, 35)
    HT_MENU_TITLE_COLOR = Color(200, 200, 200, 255)
    HT_DEFAULT_COLOR = Color(34, 34, 34)
    HT_ACCENT1 = Color(50, 50, 50)
    HT_ACCENT2 = Color(254, 113, 113)
    HT_SELECT_TEXT = HT_MENU_TITLE_COLOR
    HT_BUTTON_TEXT = HT_MENU_TITLE_COLOR
    
    HT_PLAYERBUTTONS_TEXT = HT_MENU_COLOR -- false uses job color
    HT_PLAYERBUTTONS_BUTTON = false -- false uses job color

    HT_DISCORDBUTTON_TEXT = HT_MENU_TITLE_COLOR
    HT_DISCORDBUTTON_BUTTON = Color(119, 133, 204)

    surface.CreateFont("HT_BUTTON_FONT", {
        font = "Roboto",
        extended = false,
        size = 18,
        weight = 700,
    })
    surface.CreateFont("HT_BIG_INFO", {
        font = "Roboto",
        extended = false,
        size = 22,
        weight = 400,
    })
    surface.CreateFont("HT_SMALL_INFO", {
        font = "Roboto",
        extended = false,
        size = 14,
        weight = 600,
    })
end