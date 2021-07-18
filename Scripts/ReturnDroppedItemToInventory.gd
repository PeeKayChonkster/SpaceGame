extends Control


func can_drop_data(_position, data):
	return (data.slot != null)

func drop_data(_position, data):
	data.slot.Put(data)
