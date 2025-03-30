extends Node2D

@export var semi_major_axis : float
@export var semi_minor_axis : float
@export var eccentricity : float
@export var use_eccentricity : bool

func _ready():
	#var quadrant_1_path_points = calculate_quadrant_1_path_points(10)
	#$Line2D.add_point(Vector2(100,100))
	#$Line2D.add_point(Vector2(400,400))
	var number_of_divisions = 10
	draw_ellipse(number_of_divisions - 1)


func draw_ellipse(number_of_divisions:int):
	#
	# 1. Calculations
	#
	if (use_eccentricity):
		semi_minor_axis = semi_major_axis * sqrt(1 - pow(eccentricity, 2))
	var vertices = calculate_vertices()
	var co_vertices = calculate_co_vertices()
	var q1_path_points = calculate_quadrant_1_path_points(number_of_divisions)
	var q2_path_points = calculate_quadrant_2_path_points(q1_path_points)
	var q3_path_points = calculate_quadrant_3_path_points(q2_path_points)
	var q4_path_points = calculate_quadrant_4_path_points(q3_path_points)
	var number_of_path_points = number_of_divisions - 1
	var foci = calculate_foci()
	#
	# 2. Draw Ellipse Perimeter
	#
	$Line2D.add_point(vertices[0])
	for i in range(number_of_path_points):
		$Line2D.add_point(q1_path_points[i])
	$Line2D.add_point(co_vertices[0])
	for i in range(number_of_path_points):
		$Line2D.add_point(q2_path_points[i])
	$Line2D.add_point(vertices[1])
	for i in range(number_of_path_points):
		$Line2D.add_point(q3_path_points[i])
	$Line2D.add_point(co_vertices[1])
	for i in range(number_of_path_points):
		$Line2D.add_point(q4_path_points[i])
	#
	# 3. Draw Foci
	#
	$Foci1.position = foci[0]
	$Foci2.position = foci[1]
	$Foci1.texture = load("res://orbit_point.png")
	$Foci2.texture = load("res://orbit_point.png")

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
	#print(number_of_divisions)
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


func calculate_ellipse_perimeter():
	return 2 * PI * sqrt((pow(semi_major_axis, 2) + pow(semi_minor_axis, 2))/2)


func calculate_periastron(primary_foci: Vector2):
	if(primary_foci.x != 0):
		return semi_major_axis - primary_foci.x
	else:
		return semi_minor_axis - primary_foci.y


func calculate_apastron(primary_foci: Vector2):
	if (primary_foci.x != 0):
		return 2 * semi_major_axis - primary_foci.x
	else:
		return 2 * semi_minor_axis - primary_foci.y
