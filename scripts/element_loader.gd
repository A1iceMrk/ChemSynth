extends Control

const ELEMENTS_PATH := "res://data/elements.json"

@onready var container: Node = $StarterElementsContainer

var elements: Dictionary = {}
var recipes: Array = []

#Функция запускаемая при старте (функция проверки загрузки БД ниже -> 17)
func _ready() -> void:
	var loaded := load_elements_data(ELEMENTS_PATH)
	if not loaded:
		return
	render_starter_elements()

#Функция проверки загрузки БД
func load_elements_data(path: String) -> bool:
	#Поиск файла
	if not FileAccess.file_exists(path):
		push_error("Файл не найден: "+path)
		return false
	
	#Открываем файл и проверяем пустой ли он
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Не удалось открыть файл: "+path)
		return false
	
	var raw_text := file.get_as_text()
	file.close()	
	
	#Преобразуем БД для движка и проверяем что все хорошо
	var json := JSON.new()
	var parse_result := json.parse(raw_text)
	if parse_result != OK:
		push_error("Ошибка парсинга JSON в строке %d: %s" % [json.get_error_line(), json.get_error_message()])
		return false
	
	#Проверка наличия {} в начале JSON (проверка что это объект)
	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("Корень JSON должен быть объектов (Dictionary)")
		return false
	
	#Достаем все значения после проверок
	elements = json.data.get("elements", {})
	recipes = json.data.get("recipes", [])
	return true
#Кнопки
func render_starter_elements() -> void:
	#Смотрим есть ли уже старые кнопки (для появления новых сложных элементов)
	for child in container.get_children():
		child.queue_free()
	#Перебор элементов
	for element_id in elements.keys():
		var info: Dictionary = elements[element_id]
		var is_starter: bool = bool(info.get("starter", false))
		
		if is_starter:
			var btn := Button.new()
			var el_name: String = str(info.get("name", element_id))
			var formula: String = str(info.get("formula", ""))
			var desc: String = str(info.get("desc", ""))
			
			btn.text = "%s (%s)" % [el_name, formula] if formula != "" else el_name
			btn.tooltip_text = desc
			btn.custom_minimum_size = Vector2(220, 44)
			
			btn.set_meta("element_id", element_id)
			btn.pressed.connect(_on_starter_element_pressed.bind(element_id))
			container.add_child(btn)
func _on_starter_element_pressed(element_id: String) -> void:
	print("Выбран стартовый элемент: ", element_id)
