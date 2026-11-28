extends Control

#Подгружаем сцены/файлы для дальнейшего использования
const ELEMENTS_PATH := "res://data/elements.json"
const ELEMENT_CARD_SCENE := preload("res://scenes/ElementCard.tscn")

@onready var container: Node = $StarterElementsContainer

#Создаем необходимые библиотеки и массивы
var elements: Dictionary = {}
var recipes: Array = []
var selected_ids: Array[String] = []
var cards_by_id: Dictionary = {}

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
#Карты
func render_starter_elements() -> void:
	#Смотрим есть ли уже старые карточки (для появления новых сложных элементов)
	for child in container.get_children():
		child.queue_free()
	cards_by_id.clear()
	selected_ids.clear()
	
	#Перебор элементов
	for element_id in elements.keys():
		var info: Dictionary = elements[element_id]
		var is_starter: bool = bool(info.get("starter", false))
		
		if is_starter:
			'''
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
			'''
			#Обрисовка карточки

			var card := ELEMENT_CARD_SCENE.instantiate()
			var el_name: String = str(info.get("name", element_id))
			var formula: String = str(info.get("formula", ""))
			var desc: String = str(info.get("desc", ""))
			
			container.add_child(card)
			card.setup(element_id, el_name, formula, desc)
			card.card_clicked.connect(_on_card_clicked)
			cards_by_id[element_id] = card

#Обработчик нажатия
func _on_card_clicked(element_id: String) -> void:
	if not cards_by_id.has(element_id):
		return
	
	var card = cards_by_id[element_id]
	
	#Второй раз нажали на элемент - сняли с него выбор
	if element_id in selected_ids:
		selected_ids.erase(element_id)
		card.is_selected = false
		print("Снят выбор с элемента: ", element_id)
		return
	
	#Обработка нажатия на один/два элемента и получение результата их синтеза	
	selected_ids.append(element_id)
	card.is_selected = true
	print("Выбран элемент: ", element_id, " | Выбрано сейчас: ", selected_ids)
	
	if selected_ids.size() == 2:
		var result_id := find_recipe_result(selected_ids[0], selected_ids[1])
		if result_id != "":
			print("Успешный синтез! ", selected_ids[0], " + ", selected_ids[1], " -> ", result_id)
		else:
			print("Рецепт не найден для пары: ", selected_ids[0], " + ", selected_ids[1])
		_clear_selection()

#Нахождение элементов в рецептах
func find_recipe_result(first_id: String, second_id: String) -> String:
	for recipe in recipes:
		if typeof(recipe) != TYPE_DICTIONARY:
			continue
		var a := str(recipe.get('first', ""))
		var b := str(recipe.get("second", ""))
		var output := str(recipe.get("result", ""))
		if a != "" and b != "" and output != "":
			if (a == first_id and b == second_id) or (a == second_id and b == first_id):
				return output
	return ""
	
#Убираем выделение
func _clear_selection() -> void:
	for id in selected_ids:
		if cards_by_id.has(id):
			cards_by_id[id].is_selected = false
	selected_ids.clear()
'''
func _on_starter_element_pressed(element_id: String) -> void:
	print("Выбран стартовый элемент: ", element_id)
'''
