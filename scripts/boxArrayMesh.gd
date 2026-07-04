class_name boxArrayMesh

static func make(length,width,height) -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var vertices = []
	var normals = []
	var bary = []
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)

	# cube corners
	var p000 = Vector3(0, 0, 0)
	var p001 = Vector3(0, 0, width)
	var p010 = Vector3(0, height, 0)
	var p011 = Vector3(0, height, width)
	var p100 = Vector3(length, 0, 0)
	var p101 = Vector3(length, 0, width)
	var p110 = Vector3(length, height, 0)
	var p111 = Vector3(length, height, width)

	# FRONT (+Z)
	add_tri(p001, p111, p101, Vector3(0, 0, 1), vertices, normals, bary)
	add_tri(p001, p011, p111, Vector3(0, 0, 1), vertices, normals, bary)

	# BACK (-Z)
	add_tri(p100, p010, p000, Vector3(0, 0, -1), vertices, normals, bary)
	add_tri(p100, p110, p010, Vector3(0, 0, -1), vertices, normals, bary)

	# LEFT (-X)
	add_tri(p000, p011, p001, Vector3(-1, 0, 0), vertices, normals, bary)
	add_tri(p000, p010, p011, Vector3(-1, 0, 0), vertices, normals, bary)

	# RIGHT (+X)
	add_tri(p101, p110, p100, Vector3(1, 0, 0), vertices, normals, bary)
	add_tri(p101, p111, p110, Vector3(1, 0, 0), vertices, normals, bary)

	# TOP (+Y)
	add_tri(p010, p111, p011, Vector3(0, 1, 0), vertices, normals, bary)
	add_tri(p010, p110, p111, Vector3(0, 1, 0), vertices, normals, bary)

	# BOTTOM (-Y)
	add_tri(p000, p101, p100, Vector3(0, -1, 0), vertices, normals, bary)
	add_tri(p000, p001, p101, Vector3(0, -1, 0), vertices, normals, bary)

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


static func add_tri(a, b, c, normal, vertices, normals, bary):
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
