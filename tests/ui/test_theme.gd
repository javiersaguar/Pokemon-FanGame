extends GutTest
## Theme global (contratos.md §9.4).

const MAIN_THEME := preload("res://src/ui/theme/main_theme.tres")
const POKEDOLLAR := 0x20BD


func test_theme_fonts_draw_the_money_symbol() -> void:
	var fonts: Array[Font] = [MAIN_THEME.default_font]
	for variation: StringName in [&"SmallLabel", &"SmallLightLabel", &"TagLabel"]:
		fonts.append(MAIN_THEME.get_font(&"font", variation))
	for font: Font in fonts:
		assert_true(font.has_char(POKEDOLLAR), "%s tiene ₽" % font)
		assert_true(font.has_char("P".unicode_at(0)), "y sigue siendo Truth and Ideals")


func test_battle_text_currency_is_drawable() -> void:
	assert_true(MAIN_THEME.default_font.has_char(BattleText.CURRENCY.unicode_at(0)))
