extends Node

var udp := PacketPeerUDP.new()

var current_command = {
	"left": "None",
	"right": "None"
}

var voice_command = "None"

func _ready():
	var result = udp.bind(5005, "127.0.0.1")
	if result == OK:
		print("UDP socket bound to 127.0.0.1:5005")
	else:
		push_error("Failed to bind UDP socket.")

func _process(_delta):
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var message = packet.get_string_from_utf8()

		var parsed = JSON.parse_string(message)
		if parsed and typeof(parsed) == TYPE_DICTIONARY and parsed.has("command"):
			current_command["left"] = parsed["command"]["gestures_commands"]["left"]
			current_command["right"] = parsed["command"]["gestures_commands"]["right"]
			voice_command = parsed["command"]["voice_commands"]
			
