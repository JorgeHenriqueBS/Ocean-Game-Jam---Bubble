@tool
@icon("res://addons/BulletUpHell/Sprites/NodeIcons16.png")
extends NavigationPolygon
class_name PatternCustomPoints

enum ANGLE_TYPE{FromTangeant,FromCenter,Custom}
var shape:Curve2D
var calculate_angles:int = ANGLE_TYPE.FromTangeant
var angles:Array = []
var pos:Array = []
var center_pos:Vector2
var reversed_angle:bool=false
enum SYMTYPE{ClosedShape,Line}
var symmetric:bool = false
var center:int = 0
var symmetry_type = SYMTYPE.ClosedShape

var nbr:int
var bullet:String = ""
var pattern_angle:float = 0
var iterations:int = 1
var forced_angle:float = 0.0
var forced_target:NodePath
var forced_lookat_mouse:bool = false
var forced_pattern_lookat:bool = true
var follows_parent:bool = false

#var other_scene:String
#var other_props:Dictionary = {}

var cooldown_stasis:bool = false
var cooldown_spawn:float = 0.017
var cooldown_shoot:float = 0
var cooldown_next_spawn:float = 0
var cooldown_next_shoot:float = 0

enum LATENCE {stay, move, spin, follow, target}
var wait_latence = LATENCE.stay
enum MOMENTUM{None, TRANS_LINEAR,TRANS_SINE,TRANS_QUINT,TRANS_QUART,TRANS_QUAD,TRANS_EXPO,TRANS_ELASTIC,TRANS_CUBIC, \
				TRANS_CIRC,TRANS_BOUNCE,TRANS_BACK}
var wait_tween_momentum:MOMENTUM = MOMENTUM.None
var wait_tween_length:float = 0
var wait_tween_time:float = 0

#var layer_nbr:int = 1
#var layer_cooldown_spawn:float = 0
##export (float) var cooldownshoot = 0
#var layer_pos_offset:float = 0
#var layer_speed_offset:float = 0
#var layer_angle_offset:float = 0



var r_randomisation_chances:float=1
var r_reversed_chances:float=0
var r_angles_choice:Array = []
var r_symmetry_chances:float=0
var r_bullet_choice:String
var r_bullet_nbr_choice:String
var r_bullet_nbr_variation:Vector3
var r_pattern_angle_choice:String
var r_pattern_angle_variation:Vector3
var r_infinite_iter_chances:float=0
var r_iterations_choice:String
var r_iterations_variation:Vector3
var r_forced_angle_choice:String
var r_forced_angle_variation:Vector3
var r_forced_target_choice:Array
var r_stasis_chances:float=0
var r_cooldown_spawn_choice:String
var r_cooldown_spawn_variation:Vector3
var r_cooldown_shoot_choice:String
var r_cooldown_shoot_variation:Vector3
var r_cooldown_n_spawn_choice:String
var r_cooldown_n_spawn_variation:Vector3
var r_cooldown_n_shoot_choice:String
var r_cooldown_n_shoot_variation:Vector3

var has_random
var node_target:Node2D

func _get_property_list() -> Array:
	return [
		{
			name = "bullet",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "center_pos",
			type = TYPE_VECTOR2,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "angles",
			type = TYPE_ARRAY,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "calculate_angles",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = ANGLE_TYPE,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "reversed_angle",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "pattern_angle",
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "-3.1416, 3.1416",
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "symmetric",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "center",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "symmetry_type",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = SYMTYPE,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "iterations",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "follows_parent",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Forced Angle",
			type = TYPE_NIL,
			hint_string = "forced_",
			usage = PROPERTY_USAGE_GROUP
		},{
			name = "forced_angle",
			type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "-3.1416, 3.1416",
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "forced_target",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "forced_lookat_mouse",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "forced_pattern_lookat",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Cooldowns",
			type = TYPE_NIL,
			hint_string = "cooldown",
			usage = PROPERTY_USAGE_GROUP
		},{
			name = "cooldown_stasis",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "cooldown_spawn",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "cooldown_shoot",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "cooldown_next_spawn",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "cooldown_next_shoot",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Wait",
			type = TYPE_NIL,
			hint_string = "wait_",
			usage = PROPERTY_USAGE_GROUP
		},{
			name = "wait_latence",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = LATENCE,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "wait_tween_momentum",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = MOMENTUM,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "wait_tween_length",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "wait_tween_time",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},
		#{
			#name = "Layers",
			#type = TYPE_NIL,
			#hint_string = "layer_",
			#usage = PROPERTY_USAGE_GROUP
		#},{
			#name = "layer_nbr",
			#type = TYPE_INT,
			#hint = PROPERTY_HINT_RANGE,
			#hint_string = "0, 999999",
			#usage = PROPERTY_USAGE_DEFAULT
		#},{
			#name = "layer_cooldown_spawn",
			#type = TYPE_FLOAT,
			#usage = PROPERTY_USAGE_DEFAULT
		#},{
			#name = "layer_pos_offset",
			#type = TYPE_FLOAT,
			#usage = PROPERTY_USAGE_DEFAULT
		#},{
			#name = "layer_speed_offset",
			#type = TYPE_FLOAT,
			#usage = PROPERTY_USAGE_DEFAULT
		#},{
			#name = "layer_angle_offset",
			#type = TYPE_FLOAT,
			#hint = PROPERTY_HINT_RANGE,
			#hint_string = "-3.1416, 3.1416",
			#usage = PROPERTY_USAGE_DEFAULT
		#},
		{
			name = "Random",
			type = TYPE_NIL,
			hint_string = "r_",
			usage = PROPERTY_USAGE_GROUP
		},
		{ name = "r_randomisation_chances", type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE, hint_string = "0, 1", usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_reversed_chances", type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE, hint_string = "0, 1", usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_angles_choice", type = TYPE_ARRAY, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_symmetry_chances", type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE, hint_string = "0, 1", usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_bullet_choice", type = TYPE_ARRAY, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_bullet_nbr_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_bullet_nbr_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_pattern_angle_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_pattern_angle_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_infinite_iter_chances", type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE, hint_string = "0, 1", usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_iterations_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_iterations_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_forced_angle_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_forced_angle_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_forced_target_choice", type = TYPE_ARRAY, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_stasis_chances", type = TYPE_FLOAT,
			hint = PROPERTY_HINT_RANGE, hint_string = "0, 1", usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_spawn_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_spawn_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_shoot_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_shoot_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_n_spawn_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_n_spawn_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_n_shoot_choice", type = TYPE_STRING, usage = PROPERTY_USAGE_DEFAULT },
		{ name = "r_cooldown_n_shoot_variation", type = TYPE_VECTOR3, usage = PROPERTY_USAGE_DEFAULT }]

func _init():
	resource_name = "PatternCustomPoints"

#func _get_property_list() -> Array:
#	return [
#		{
#			name = "closed_shape",
#			type = TYPE_BOOL,
#			usage = PROPERTY_USAGE_DEFAULT
#		}]
