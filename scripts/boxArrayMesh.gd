class_name boxArrayMesh

static func make(length,width,height) -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var vertices = []
	var normals = []
	var bary = []
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	# FRONT (+Z)
	_add_face(length,width,height,Vector3(0,0,1),vertices,normals,bary)
	# BACK (-Z)
	_add_face(length,width,height,Vector3(0,0,-1),vertices,normals,bary)
	# LEFT (-X)
	_add_face(length,width,height,Vector3(-1,0,0),vertices,normals,bary)
	# RIGHT (+X)
	_add_face(length,width,height,Vector3(1,0,0),vertices,normals,bary)
	# TOP (+Y)
	_add_face(length,width,height,Vector3(0,1,0),vertices,normals,bary)
	# BOTTOM (-Y)
	_add_face(length,width,height,Vector3(0,-1,0),vertices,normals,bary)

	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(normals)

	var uvs := PackedVector2Array()

	for b in bary:
		uvs.push_back(Vector2(b.x, b.y))

	arrays[Mesh.ARRAY_TEX_UV] = uvs

	var flags = Mesh.ARRAY_FORMAT_TEX_UV

	mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays,
		[],
		{},
		flags
	)
	return mesh


static func _make_from_array(voxels: Array, spacing) -> ArrayMesh:
	
	var mesh = ArrayMesh.new()
	var vertices = []
	var normals = []
	var bary = []
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	for i in range(voxels.size()):
		var curCell = voxels[i]
		var neighborAdjustments = [[1,0,0],
								[-1,0,0],
								[0,1,0],
								[0,-1,0],
								[0,0,1],
								[0,0,-1]]
		for n in range(neighborAdjustments.size()):
			var curNeighborCell = [curCell[0] + neighborAdjustments[n][0],
								curCell[1] + neighborAdjustments[n][1],
								curCell[2] + neighborAdjustments[n][2]]
			var free = true
			for j in range(voxels.size()):
				var testCell = voxels[j]
				if testCell == curNeighborCell:
					free = false
					break
			if free:
				_add_face(spacing,spacing,spacing,
						Vector3(neighborAdjustments[n][0],neighborAdjustments[n][2],neighborAdjustments[n][1]),
						vertices, normals, bary,
						Vector3(curCell[0],curCell[2],curCell[1]))
	
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(normals)

	var uvs := PackedVector2Array()

	for b in bary:
		uvs.push_back(Vector2(b.x, b.y))

	arrays[Mesh.ARRAY_TEX_UV] = uvs

	var flags = Mesh.ARRAY_FORMAT_TEX_UV

	mesh.add_surface_from_arrays(
		Mesh.PRIMITIVE_TRIANGLES,
		arrays,
		[],
		{},
		flags
	)
	return mesh


static func _add_face(length,width,height, normal, vertices, normals, bary, origin: Vector3 = Vector3(0,0,0)):
	var p000 = Vector3(0, 0, 0) + origin
	var p001 = Vector3(0, 0, width) + origin
	var p010 = Vector3(0, height, 0) + origin
	var p011 = Vector3(0, height, width) + origin
	var p100 = Vector3(length, 0, 0) + origin
	var p101 = Vector3(length, 0, width) + origin
	var p110 = Vector3(length, height, 0) + origin
	var p111 = Vector3(length, height, width) + origin
	# FRONT (+Z)
	if normal == Vector3(0, 0, 1):
		_add_tri(p001, p111, p101, normal, vertices, normals, bary)
		_add_tri(p001, p011, p111, normal, vertices, normals, bary)

	# BACK (-Z)
	if normal == Vector3(0, 0, -1):
		_add_tri(p100, p010, p000, normal, vertices, normals, bary)
		_add_tri(p100, p110, p010, normal, vertices, normals, bary)

	# LEFT (-X)
	if normal == Vector3(-1, 0, 0):
		_add_tri(p000, p011, p001, normal, vertices, normals, bary)
		_add_tri(p000, p010, p011, normal, vertices, normals, bary)

	# RIGHT (+X)
	if normal == Vector3(1, 0, 0):
		_add_tri(p101, p110, p100, normal, vertices, normals, bary)
		_add_tri(p101, p111, p110, normal, vertices, normals, bary)

	# TOP (+Y)
	if normal == Vector3(0, 1, 0):
		_add_tri(p010, p111, p011, normal, vertices, normals, bary)
		_add_tri(p010, p110, p111, normal, vertices, normals, bary)

	# BOTTOM (-Y)
	if normal == Vector3(0, -1, 0):
		_add_tri(p000, p101, p100, normal, vertices, normals, bary)
		_add_tri(p000, p001, p101, normal, vertices, normals, bary)
	
static func _add_tri(a, b, c, normal, vertices, normals, bary):
		# triangle 1
		vertices.append(a)
		vertices.append(b)
		vertices.append(c)

		normals.append(normal)
		normals.append(normal)
		normals.append(normal)

		var abDist = a.distance_to(b)
		var bcDist = b.distance_to(c)
		var caDist = c.distance_to(a)
		
		if abDist >= bcDist and abDist >= caDist:
			bary.append(Vector3(1, 0, 0))
			bary.append(Vector3(0, 0, 1))
			bary.append(Vector3(0, 1, 0))
		if bcDist >= abDist and bcDist >= caDist:
			bary.append(Vector3(0, 1, 0))
			bary.append(Vector3(1, 0, 0))
			bary.append(Vector3(0, 0, 1))
		if caDist >= abDist and caDist >= bcDist:
			bary.append(Vector3(1, 0, 0))
			bary.append(Vector3(0, 1, 0))
			bary.append(Vector3(0, 0, 1))
