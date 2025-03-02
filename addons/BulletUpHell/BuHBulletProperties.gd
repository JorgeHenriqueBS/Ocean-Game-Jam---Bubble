@tool
extends Path2D

@export var id:String = ""
@export var props:PackedDataContainer

const ATEXTURE:int = 0
const ACOLLISION:int = 1
const ASFX:int = 2


func _ready():
	randomize()
	add_to_group("BulletProps")
	if Engine.is_editor_hint():
		if not props: props = BulletProps.new()
		return
	
	if not props is ObjectProps:
		if props.homing_type == props.TARGET_TYPE.ListPositions:
			props.homing_list = props.homing_list_pos.duplicate()
		elif props.homing_type == props.TARGET_TYPE.ListNodes:
			props.homing_list = []
			for n in props.homing_list_nodes: props.homing_list.append(get_node(n))
		elif props.homing_type == props.TARGET_TYPE.MouseCursor:
			props.homing_mouse = true
		if props.homing_target: props.node_homing = get_node(props.homing_target)
		elif props.homing_special_target: props.node_homing = Spawning.get_special_target(props.homing_special_target)
		elif not (props.homing_list.size() < 2 or props.homing_list_ordered): props.homing_list.shuffle()
		
		if props.get("a_curve_movement") > 0:
			assert(curve.get_point_count() > 0, \
				"BulletProperties has no curve. Draw one like you'd draw a Path2D with the BulletPattern node")
			props.curve = curve
	
	var dict:Dictionary = {}; var P; var has_random:bool=false;
	var anim_state_name:String
	var allow_random:bool = (props is ObjectProps or randf_range(0,1) <= props.get("r_randomisation_chances"));
	for p in props.get_property_list():
		P = p["name"]
		if P in ["__data__","spec_top_level","spec_ally","a_angular_equation","mask","r_randomisation_chances",
			"RefCounted","Resource","resource_local_to_scene","resource_path","Resource","node_container",
			"resource_name","PackedDataContainer","script","Script Variables","homing_position", "homing_list_ordered", "homing_type",
			"homing_list_pos","homing_list_nodes","Advanced Movement","Advanced Scale","Animations","Homing","Special Properties",
			"Triggers","Destruction","Laser Beam","BulletProps.gd","Random"]:
				continue
		elif P in ["a_direction_equation","trigger_container", "anim_spawn_texture","anim_waiting_texture",\
			"anim_delete_texture","anim_spawn_collision","anim_waiting_collision","anim_delete_collision",\
			"homing_special_target","homing_group"] and props.get(P) == "": continue
		elif P in ["a_speed_multi_iterations","scale_multi_iterations","spec_bounces","spec_rotating_speed", \
			"spec_warn","spec_explo","spec_skew","spec_modulate_loop","beam_length_per_ray","spec_trail_length",\
			"a_curve_movement"] and int(props.get(P)) == int(0): continue
		elif P in ["anim_idle_sfx","anim_spawn_sfx","anim_waiting_sfx","anim_delete_sfx"] and props.get(P) == -1: continue
		elif P in ["spec_tourment","spec_no_collision","overwrite_groups","homing_mouse"] and props.get(P) == false: continue
		elif P == "homing_target" and props.get(P) == NodePath(): continue
		elif P == "homing_position" and props.get(P) == Vector2(): continue
		elif P in ["spec_modulate","curve"] and props.get(P) == null: continue
		elif P in ["homing_list","homing_surface","groups"] and props.get(P).is_empty(): continue
		elif P == "death_outside_box" and props.get(P) == Rect2(): continue
		
		elif P in ["homing_steer","homing_time_start","homing_duration","node_homing"] \
			and not ((dict.get("homing_target",false) or dict.get("homing_position",false)) \
			or (dict.get("homing_group",false) or dict.get("homing_special_target",false)) \
			or (dict.get("homing_surface",false) or dict.get("homing_mouse",false) or dict.get("homing_list",false))): continue
		elif P in ["a_speed_multiplier","a_speed_multi_scale"] \
			and not dict.get("a_speed_multi_iterations",false): continue
		elif P in ["scale_multiplier","scale_multi_scale"] \
			and not dict.get("scale_multi_iterations",false): continue
		elif P in ["beam_width","beam_bounce_amount"] \
			and not dict.get("beam_length_per_ray",false): continue
		elif P == "trigger_wait_for_shot" and not dict.has("trigger_container"): continue
		elif P == "homing_select_in_group" and not (dict.has("homing_group") or dict.has("homing_mouse")): continue
		elif P in ["homing_when_list_ends"] and not dict.has("homing_list"): continue
		elif P in ["spec_trail_modulate","spec_trail_width"] and not dict.has("spec_trail_length"): continue
		
		#elif P.left(5) == "anim_":
			#for a in props.get(P):
				#anim_state_name = "anim_"+a.ID
				#dict[anim_state_name] = [a.texture, Spawning.arrayShapes[a.collision],$SFX.get_node(a.SFX)]
				##if dict[anim_state_name][ATEXTURE] == "": dict[anim_state_name][ATEXTURE] = default_anim.texture
				##if dict[anim_state_name][ACOLLISION] == "": dict[anim_state_name][ACOLLISION] = default_anim.collision
				##if dict[anim_state_name][ASFX] == "": dict[anim_state_name][ASFX] = default_anim.SFX
			#if not dict.has("anim_idle"):
				#dict["anim_idle"] = [default_anim.texture, arrayShapes[default_anim.collision], $SFX.get_node(default_anim.SFX)]
			#if dict.has("anim_spawn"): dict["first_collision"] = dict["anim_spawn"][ACOLLISION]
			#else: dict["first_collision"] = dict["anim_idle"][ACOLLISION]
			#continue
		
		elif P.left(2) == "r_":
			if not allow_random or \
			(p["type"] == TYPE_STRING and props.get(P) == "") or \
			(p["type"] == TYPE_VECTOR3 and props.get(P) == Vector3()) or \
			(p["type"] == TYPE_FLOAT and props.get(P) == 0.0) or \
			(p["type"] == TYPE_ARRAY and props.get(P).is_empty()): continue
			
			if not has_random:
				has_random = true
				dict["has_random"] = true
			
			if p["type"] == TYPE_STRING:
				dict[P] = Array(props.get(P).split(";",false))
				continue
		
		elif P == "instance_id":
			assert(props.get(P) != "", "Instance_ID field can't be empty in node "+name)
			if ";" in props.get(P): props.set(P, Array(props.get(P).split(";",false)))
		
		if ("anim_" in P and not "_sfx" in P) and ";" in props.get(P):
			props.set(P, Array(props.get(P).split(";",false)))
		dict[P] = props.get(P)
	dict["__ID__"] = id
	Spawning.new_bullet(id, dict)
	queue_free()
