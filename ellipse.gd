class_name Ellipse extends Node2D

# Properties
@export_category("Elliptical Properties")
@export var semi_major_axis: float = 100
@export var semi_minor_axis: float = 50
@export_range(0, 1) var eccentricity: float = 0.5
@export var use_eccentricity: bool = false
@export var foci_1_position: Vector2
@export var foci_2_position: Vector2
@export_category("Elliptical Instance Properties")
@export_range(1, 20) var resolution: int = 5
@export var points: Array
@export var show_foci_1: bool = false
@export var show_foci_2: bool = false
@export_category("Elliptical Orbit Properties")
@export var orbital_period: float = 1
@export_range(1, 50) var time_dilation: float = 1
@export var point_velocity: Array = []
@export var standard_graviational_parameter: float = 1
@export_range(1,2) var foci_of_central_body: int = 1

signal send_point_info_to_orbit(point_array, point_velocity_array)

# Virtual Methods
func _ready():
	calculate_ellipse()
	send_point_info_to_orbit.emit(points, point_velocity)
	#print(points)
	path_ellipse()
	draw_ellipse()
	pass


# Methods
func calculate_ellipse():
	# Calculate Elliptical Parameters
	if (use_eccentricity):
		semi_minor_axis = semi_major_axis * sqrt(1 - pow(eccentricity, 2))
	var foci = calculate_foci()
	foci_1_position = foci[0]
	foci_2_position = foci[1]
	
	# Calculate Elliptical Instance Parameters
	var vertices = calculate_vertices()
	var co_vertices = calculate_co_vertices()
	var q1_path_points = calculate_quadrant_1_path_points(resolution)
	var q2_path_points = calculate_quadrant_2_path_points(q1_path_points)
	var q3_path_points = calculate_quadrant_3_path_points(q2_path_points)
	var q4_path_points = calculate_quadrant_4_path_points(q3_path_points)
	points.append(vertices[0])
	for point in q1_path_points:
		points.append(point)
	points.append(co_vertices[0])
	for point in q2_path_points:
		points.append(point)
	points.append(vertices[1])
	for point in q3_path_points:
		points.append(point)
	points.append(co_vertices[1])
	for point in q4_path_points:
		points.append(point)
	points.append(vertices[0])
	
	# Calculate Elliptical Orbit Parameters
	standard_graviational_parameter = calculate_standard_gravitational_parameter()
	point_velocity = calculate_point_velocities()


func path_ellipse():
	for point in points:
		$Path2D.curve.add_point(point)


func draw_ellipse():
	for point in points:
		$Line2D.add_point(point)


func calculate_foci():
	var output = Array()
	if (semi_major_axis > semi_minor_axis):
		var c = sqrt((semi_major_axis * semi_major_axis) - (semi_minor_axis * semi_minor_axis))
		output.append(Vector2(c, 0))
		output.append(Vector2(-c, 0))
	else:
		var c = sqrt((semi_minor_axis * semi_minor_axis) - (semi_major_axis * semi_major_axis))
		output.append(Vector2(0,  c))
		output.append(Vector2(0, -c))
	return output


func calculate_vertices():
	var v = Array()
	v.append(Vector2( semi_major_axis, 0))
	v.append(Vector2(-semi_major_axis, 0))
	return v


func calculate_co_vertices():
	var cv = Array()
	cv.append(Vector2(0,  semi_minor_axis))
	cv.append(Vector2(0, -semi_minor_axis))
	return cv


func calculate_quadrant_1_path_points(number_of_divisions:int = 2):
	# Stolen from:
	# https://math.stackexchange.com/questions/2796214/dividing-an-ellipse-into-equal-area
	# 
	var q1 = Array()
	for n in range(number_of_divisions - 1):
		var theta_k = (n+1) * PI / (2 * number_of_divisions)
		#print(n,"|Theta_K: ", theta_k)
		var tangent = tan(theta_k)
		#print(n, "|Tangent: ", tangent)
		var x = sqrt(pow(semi_major_axis, 2) / (pow(tangent, 2) + 1))
		#print(n, "|X: ", x)
		#var y = sqrt(pow(semi_minor_axis, 2) / (pow(tangent, 2) + 1))
		# Never before have I been so confused.
		# Never.
		# If you want to understand why this comment is here,
		# comment out line 45 and enable line 40. Jesus.
		var y = sqrt(pow(semi_minor_axis, 2) * (1 - (pow(x,2) / pow(semi_major_axis, 2))))
		#print(n, "|Y: ", y)
		q1.append(Vector2(x, y))
	return q1


func calculate_quadrant_2_path_points(quadrant_1_path_points):
	var q2 = Array()
	var l = len(quadrant_1_path_points)
	for i in range(l):
		q2.append(Vector2(-quadrant_1_path_points[l - (i + 1)].x, quadrant_1_path_points[l - (i + 1)].y))
	return q2


func calculate_quadrant_3_path_points(quadrant_2_path_points):
	var q3 = Array()
	var l = len(quadrant_2_path_points)
	for i in range(l):
		q3.append(Vector2(quadrant_2_path_points[l - (i + 1)].x, -quadrant_2_path_points[l - (i + 1)].y))
	return q3


func calculate_quadrant_4_path_points(quadrant_3_path_points):
	var q4 = Array()
	var l = len(quadrant_3_path_points)
	for i in range(l):
		q4.append(Vector2(-quadrant_3_path_points[l - (i + 1)].x, quadrant_3_path_points[l - (i + 1)].y))
	return q4


func calculate_standard_gravitational_parameter():
	return (4 * pow(PI, 2) * pow(semi_major_axis, 3)) / pow((orbital_period * time_dilation), 2)


func calculate_point_velocities():
	var output = Array()
	for point in points:
		output.append(calculate_point_velocity(point))
	return output


func calculate_point_velocity(point: Vector2):
	var distance = calculate_distance_from_central_body(point)
	#print("Distance: ", distance)
	return sqrt(standard_graviational_parameter * ((2 / distance) - (1 / semi_major_axis)))


func calculate_distance_from_central_body(point: Vector2):
	var foci = foci_1_position if (foci_of_central_body == 1) else foci_2_position
	return foci.distance_to(point)
