class_name Page
extends Control

signal animation_started
signal animation_ended(animation: Tween)

const ANIMATION_DURATION: float = 1.3
const FADE_DURATION: float = .95
const START_FADE_DELAY: float = .25


func _ready() -> void:
	animation_ended.connect(_on_animation_ended)


func _do_animation(
	target_position: Vector2,
	target_modulate: Color,
	initial_position: Vector2 = Vector2.ZERO,
	initial_modulate: Color = Color.WHITE,
	start_fade_delay: float = 0.0,
	ease_type: Tween.EaseType = Tween.EASE_OUT,
	trans_type: Tween.TransitionType = Tween.TRANS_CUBIC
	) -> void:
	position = initial_position
	modulate = initial_modulate
	
	animation_started.emit()
	
	var position_tween = create_tween()
	position_tween.set_ease(ease_type)
	position_tween.set_trans(trans_type)
	position_tween.tween_property(self, ^"position", target_position, ANIMATION_DURATION)
	position_tween.play()
	
	if start_fade_delay > 0:
		await get_tree().create_timer(start_fade_delay).timeout
	
	var color_tween = create_tween()
	color_tween.set_ease(ease_type)
	color_tween.set_trans(trans_type)
	color_tween.tween_property(self, ^"modulate", target_modulate, FADE_DURATION)
	color_tween.play()
	
	await color_tween.finished
	
	if modulate == Color.TRANSPARENT:
		position_tween.kill()
	
	animation_ended.emit(color_tween)


func animate_in() -> void:
	_do_animation(Vector2.ZERO, Color.WHITE, Vector2.ZERO, Color.TRANSPARENT)

func animate_in_from_left() -> void:
	_do_animation(Vector2.ZERO, Color.WHITE, Vector2(-310, 0), Color.TRANSPARENT, START_FADE_DELAY)

func animate_in_from_right() -> void:
	_do_animation(Vector2.ZERO, Color.WHITE, Vector2(310, 0), Color.TRANSPARENT, START_FADE_DELAY)

func animate_in_from_up() -> void:
	_do_animation(Vector2.ZERO, Color.WHITE, Vector2(0, -485), Color.TRANSPARENT, START_FADE_DELAY)

func animate_in_from_down() -> void:
	_do_animation(Vector2.ZERO, Color.WHITE, Vector2(0, 485), Color.TRANSPARENT, START_FADE_DELAY)


func animate_out() -> void:
	_do_animation(Vector2.ZERO, Color.TRANSPARENT, Vector2.ZERO, Color.WHITE)

func animate_out_to_left() -> void:
	_do_animation(Vector2(-310, 0), Color.TRANSPARENT, Vector2.ZERO, Color.WHITE, 0.0, Tween.EASE_IN)

func animate_out_to_right() -> void:
	_do_animation(Vector2(310, 0), Color.TRANSPARENT, Vector2.ZERO, Color.WHITE, 0.0, Tween.EASE_IN)

func animate_out_to_up() -> void:
	_do_animation(Vector2(0, -485), Color.TRANSPARENT, Vector2.ZERO, Color.WHITE, 0.0, Tween.EASE_IN)

func animate_out_to_down() -> void:
	_do_animation(Vector2(0, 485), Color.TRANSPARENT, Vector2.ZERO, Color.WHITE, 0.0, Tween.EASE_IN)


func change_page_to(new_page_scene: PackedScene, in_animation_str: String, out_animation_str: String) -> void:
	var page_scene = new_page_scene
	if not page_scene or not page_scene.can_instantiate():
		return
	call(out_animation_str)
	var page: Page = page_scene.instantiate()
	add_sibling(page)
	page.call(in_animation_str)
	await animation_ended
	queue_free()


func _on_animation_ended(animation: Tween) -> void:
	animation.kill()
