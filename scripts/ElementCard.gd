extends PanelContainer

#При нажатии - ответ от родительского файла
signal card_clicked(element_id: String)

#Сыллка на наименование
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var formula_label: Label = $VBoxContainer/FormulaLabel

#Постоянно обновляем карточку
signal card_clicked(element_id: String)

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var formula_label: Label = $VBoxContainer/FormulaLabel

var element_id: String = ""
var is_selected: bool = false:
	set(value):
		is_selected = value
		_update_visual_state()

#Настраиванем карточку
func setup(p_element_id: String, el_name: String, formula: String = "", desc: String = "") -> void:
	element_id = p_element_id
	title_label.text = el_name
	formula_label.text = formula
	formula_label.visible = formula != ""
	tooltip_text = desc
	_update_visual_state()

#ТОЧНО НАЖАТА ЛЕВАЯ КНОПКА МЫШИ?????
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(element_id)
		accept_event()

#Обновление карточки с цветом
func _update_visual_state() -> void:
	modulate = Color(1.25, 1.25, 0.85, 1.0) if is_selected else Color(1.0, 1.0, 1.0, 1.0)
