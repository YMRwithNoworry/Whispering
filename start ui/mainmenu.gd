# MainMenu.gd - 极简单按钮版
extends Control

@onready var glitch_overlay = $GlitchOverlay
@onready var title_label = $TitleLabel
@onready var start_button = $StartButton

var glitch_timer := 0.0
var is_glitching := false
var elapsed_time := 0.0

func _ready():
	setup_ui()
	setup_signals()
	glitch_timer = randf_range(3.0, 6.0)

func setup_ui():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://start ui/glitch_enhanced.gdshader")
	shader_material.set_shader_parameter("glitch_intensity", 0.08)
	shader_material.set_shader_parameter("chromatic_aberration", 5.0)
	glitch_overlay.material = shader_material
	
	# 标题样式
	title_label.add_theme_font_size_override("font_size", 56)
	
	# 开始按钮样式（居中）
	start_button.custom_minimum_size = Vector2(360, 60)
	start_button.add_theme_font_size_override("font_size", 24)
	start_button.pivot_offset = start_button.custom_minimum_size / 2
	start_button.position = Vector2(
		get_viewport().size.x / 2 - start_button.custom_minimum_size.x / 2,
		get_viewport().size.y * 0.7)
	#var glow = Color(0.3, 0.9, 1.0, 0.5)
	#start_button.add_theme_color_override("font_outline_color", glow)
	#start_button.add_theme_constant_override("outline_size", 2)
	
	# 呼吸动画
	var breathe_tween = create_tween().set_loops()
	breathe_tween.tween_property(start_button, "modulate:a", 0.85, 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe_tween.tween_property(start_button, "modulate:a", 1.0, 2.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta):
	elapsed_time += delta
	var material = glitch_overlay.material as ShaderMaterial
	material.set_shader_parameter("time", elapsed_time)
	
	glitch_timer -= delta
	if glitch_timer <= 0 and not is_glitching:
		trigger_glitch()
		glitch_timer = randf_range(3.0, 6.0)

func trigger_glitch():
	is_glitching = true
	var material = glitch_overlay.material as ShaderMaterial
	
	material.set_shader_parameter("glitch_intensity", 0.5)
	material.set_shader_parameter("chromatic_aberration", 15.0)
	
	# 屏幕闪烁
	var flash_tween = create_tween()
	flash_tween.tween_property(glitch_overlay, "modulate:a", 0.85, 0.05)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(glitch_overlay, "modulate:a", 1.0, 0.05)
	
	await get_tree().create_timer(randf_range(0.2, 0.5)).timeout
	recover_from_glitch()

func recover_from_glitch():
	var material = glitch_overlay.material as ShaderMaterial
	var tween = create_tween()
	
	tween.tween_method(
		func(val): material.set_shader_parameter("glitch_intensity", val),
		0.5, 0.08, 0.6
	).set_trans(Tween.TRANS_QUAD)
	
	tween.parallel().tween_method(
		func(val): material.set_shader_parameter("chromatic_aberration", val),
		15.0, 5.0, 0.6
	).set_trans(Tween.TRANS_QUAD)
	
	await tween.finished
	is_glitching = false

func _on_button_hover(button: Button, hovered: bool):
	create_tween().tween_property(button, "scale", 
		Vector2(1.15, 1.15) if hovered else Vector2.ONE, 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#create_tween().tween_property(button, "modulate",
		#Color(0.0, 0.0, 0.0, 1.0) if hovered else Color.WHITE, 0.12)

func _on_start_pressed():
	trigger_glitch()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func setup_signals():
	start_button.mouse_entered.connect(_on_button_hover.bind(start_button, true))
	start_button.mouse_exited.connect(_on_button_hover.bind(start_button, false))
	start_button.pressed.connect(_on_start_pressed)
