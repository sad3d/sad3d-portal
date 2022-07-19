extends Popup


export var is_enabled = true


onready var crosshair = $"../Crosshair"
onready var hint = $"../Hint"
onready var subtitles = $"../Subtitles"

onready var pause_menu = $PauseMenu

onready var skills_menu = $SkillsMenu
onready var loneliness_value = $SkillsMenu/LonelinessValue
onready var corporeality_value = $SkillsMenu/CorporealityValue
onready var reflexion_value = $SkillsMenu/ReflexionValue

onready var book_menu = $BookMenu
onready var book_title = $BookMenu/BookTitle
onready var book_text = $BookMenu/BookText

onready var phone_menu =  $PhoneMenu
onready var phone_text = $PhoneMenu/MarginContainer/PhoneText
onready var phone_texture = $PhoneMenu/PhoneTexture
export (Array, Texture) var phone_texture_list

func _input(event):
	if is_enabled:
		
		if event.is_action_pressed("ui_cancel"):
			if get_tree().paused:
				continue_game()
			else:
				pause_game()
				
		if event.is_action_pressed("skills_menu"):
			if !get_tree().paused:
				show_skills()
		
		if event.is_action_released("skills_menu"):
			if !get_tree().paused:
				hide_skills()


func _on_Continue_Button_pressed():
	continue_game()


func _on_MainMenuButton_pressed():
	load_main_menu()


func _on_Quit_Button_pressed():
	quit_game()


func continue_game():
	
	crosshair.show()
	hint.show()
	subtitles.show()
	
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	pause_menu.hide()
	skills_menu.hide()
	book_menu.hide()
	phone_menu.hide()
	hide()


func pause_game():
	
	crosshair.hide()
	hint.hide()
	subtitles.hide()
	
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	pause_menu.show()
	skills_menu.hide()
	book_menu.hide()
	phone_menu.hide()
	popup()


func show_skills():
	crosshair.hide()
	hint.hide()
	subtitles.hide()
	
	loneliness_value.text = String(PlayerVariables.loneliness)
	corporeality_value.text = String(PlayerVariables.corporeality)
	reflexion_value.text = String(PlayerVariables.reflexion)
	
	pause_menu.hide()
	skills_menu.show()
	book_menu.hide()
	phone_menu.hide()
	popup()
	

func hide_skills():
	crosshair.show()
	hint.show()
	subtitles.show()
	
	pause_menu.hide()
	skills_menu.hide()
	book_menu.hide()
	phone_menu.hide()
	hide()
	
	
func show_book_text(_book_title : String, _book_text : String):
	
	book_title.text = tr(_book_title)
	book_text.bbcode_text = tr(_book_text)
	
	crosshair.hide()
	hint.hide()
	subtitles.hide()
	
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	pause_menu.hide()
	skills_menu.hide()
	book_menu.show()
	phone_menu.hide()
	popup()
	
	
func show_phone_text(_phone_text : String, _phone_variant : int):
	
	phone_text.bbcode_text = tr(_phone_text)
	if _phone_variant <= -1 || _phone_variant >= phone_texture_list.size():
		phone_texture.texture = phone_texture_list[randi() % phone_texture_list.size()]
	else:
		phone_texture.texture = phone_texture_list[_phone_variant]
	
	crosshair.hide()
	hint.hide()
	subtitles.hide()
	
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	pause_menu.hide()
	skills_menu.hide()
	book_menu.hide()
	phone_menu.show()
	popup()
	
	
func load_main_menu():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	
	
func quit_game():
	get_tree().paused = false
	get_tree().quit()
