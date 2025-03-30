extends PathFollow2D

var points
var point_velocity

var number_of_points: int
var velocity: float
var point_increment: float
var current_point: int = 0
var ready_to_go: bool = false



# Virtual Methods
func _ready():
	pass


func _process(delta):
	if (ready_to_go):
		var increment = delta * velocity
		progress_ratio += increment
		#print("Progress Ratio: ", progress_ratio)
		if progress_ratio >= ((current_point * point_increment) + point_increment):
			current_point += 1
			print("Current Point: ", current_point)
			update_velocity()
			#print(velocity)
		elif progress_ratio < point_increment:
			current_point = 0
			print("Current Point: ", current_point)
			update_velocity()
		


func update_velocity():
	velocity = point_velocity[current_point]
	print("Velocity: ", velocity)


func _on_elliptical_orbit_send_point_info_to_orbit(point_array, point_velocity_array):
	points = point_array
	print("Points: ", points)
	point_velocity = point_velocity_array
	print("Point Velocities: ", point_velocity)
	number_of_points = len(points)
	print("Number of Points: ", number_of_points)
	point_increment = pow(number_of_points, -1)
	print("Point Increment ", point_increment)
	update_velocity()
	ready_to_go = true
