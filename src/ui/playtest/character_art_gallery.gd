class_name CharacterArtGallery
extends RefCounted

static func open() -> void:
	var entries := CharacterArt.entries()
	var ids: Array = entries.keys()
	ids.sort_custom(func(a: String,b: String) -> bool: return str(entries[a].get("name",a)) < str(entries[b].get("name",b)))
	var names := PackedStringArray()
	for id: String in ids: names.append(str(entries[id].get("name",id)))
	while not names.is_empty():
		var selected := await ChoiceScreen.pick("Personajes / combate y mapa",names)
		if selected < 0: return
		await CharacterArtPreview.open(StringName(ids[selected]))
