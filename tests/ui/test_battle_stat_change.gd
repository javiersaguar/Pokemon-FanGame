extends GutTest
func test_subida_y_bajada_se_mueven_en_sentidos_opuestos_con_etiqueta() -> void:
	var parent := Node2D.new()
	add_child_autofree(parent)
	var up := BattleStatChange.create(parent,Vector2(160,160),"atk",2)
	var down := BattleStatChange.create(parent,Vector2(350,160),"def",-1)
	up.progress = 0.3
	down.progress = 0.3
	var up_y := up.particles[0].position.y
	var down_y := down.particles[0].position.y
	up.progress = 0.6
	down.progress = 0.6
	assert_lt(up.particles[0].position.y,up_y)
	assert_gt(down.particles[0].position.y,down_y)
	assert_eq(up.caption.text,"+2 Ataque")
	assert_eq(down.caption.text,"-1 Defensa")
	assert_eq(up.particles[0].scale,Vector2.ONE)
	assert_eq(down.particles[0].rotation,0.0)

func test_reduccion_conserva_la_informacion_sin_particulas() -> void:
	var parent := Node2D.new()
	add_child_autofree(parent)
	var fx := BattleStatChange.create(parent,Vector2(340,100),"spe",-2,true)
	fx.progress = 0.5
	assert_true(fx.particles.all(func(particle: Sprite2D) -> bool: return not particle.visible))
	assert_eq(fx.caption.text,"-2 Velocidad")
	assert_eq(fx.caption.modulate.a,1.0)
