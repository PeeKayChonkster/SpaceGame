extends Item

export (float) var thrust
export (float) var maxSpeed
export (float) var torque
export (float) var breaks


func GetInformation():
	var info = .GetInformation()
	# remove description
	var _bul = info.pop_back()
	info.append("Thrust: " + str(thrust))
	info.append("Max speed: " + str(maxSpeed))
	info.append("Torque: " + str(torque))
	info.append("Breaks: " + str(breaks))
	info.append("Description: " + description)
	return info
