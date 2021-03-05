tool
extends Label

export(int, 0, 100, 1) var size = 16 setget _set_size
export var icon = "" setget _set_icon

const ttf = preload("fontawesome-webfont.ttf")
const Cheatsheet = preload("Cheatsheet.gd").Cheatsheet
var _font = DynamicFont.new()

func _init():
    _font.set_font_data(ttf)
    set("custom_fonts/font", _font)

func _set_size(p_size):
    size = p_size
    if is_inside_tree():
        _font.set_size(p_size)

func _set_icon(p_icon):
    icon = p_icon
    if is_inside_tree():
        var iconcode = ""
        if p_icon in Cheatsheet:
            iconcode = Cheatsheet[p_icon]
        set_text(iconcode)

func _ready():
    self.size = size
    self.icon = icon
