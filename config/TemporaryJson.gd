extends Node

static func get_universe(jsonStr : String) -> Dictionary:
	# note, vectors need to be stored as 
	# var2str(Vector2(0,0)) and parsed backwards
	
	jsonStr = "{\"entry_point\":\"level1\",\"points\":{\"level1\":{\"name\":\"No Secrets Here\",\"position\":\"Vector2( 500, 100 )\",\"type\":\"level\",\"attributes\":{\"standard_clear\":\"right\",\"secret_clear\":\"down\"}},\"level2\":{\"name\":\"Told Ya\",\"position\":\"Vector2( 900, 100 )\",\"type\":\"level\",\"attributes\":{\"standard_clear\":null,\"secret_clear\":null}},\"secret1\":{\"name\":\"Definitely No Secrets Here\",\"position\":\"Vector2( 500, 500 )\",\"type\":\"level\",\"attributes\":{\"standard_clear\":\"right\",\"secret_clear\":\"left\"}},\"star_world\":{\"name\":\"Ok You Found Me\",\"position\":\"Vector2( 100, 300 )\",\"type\":\"level\",\"attributes\":{\"standard_clear\":\"right\",\"secret_clear\":null}},\"path1\":{\"name\":\"path1\",\"position\":\"Vector2( 700, 300 )\",\"type\":\"path\"},\"path2\":{\"name\":\"path2\",\"position\":\"Vector2( 700, 700 )\",\"type\":\"path\"},\"path3\":{\"name\":\"path3\",\"position\":\"Vector2( 900, 500 )\",\"type\":\"path\"}},\"paths\":{\"right\":{\"level1\":{\"dest\":\"path1\"},\"path1\":{\"dest\":\"level2\"},\"secret1\":{\"dest\":\"path2\"},\"path2\":{\"dest\":\"path3\"},\"star_world\":{\"dest\":\"level1\"}},\"up\":{\"level1\":{\"dest\":\"path1\"},\"path3\":{\"dest\":\"level2\"}},\"down\":{\"level1\":{\"dest\":\"secret1\"}},\"left\":{\"secret1\":{\"dest\":\"star_world\"}}}}"

	var res = str2var(jsonStr)
	
	for level in res.points.keys():
		res.points[level].position = str2var(res.points[level].position)
		pass
	
	
	return res
