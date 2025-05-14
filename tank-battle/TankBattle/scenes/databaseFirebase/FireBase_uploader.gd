extends Node

const FB_DB_URL = "https://game-tank-battle-default-rtdb.firebaseio.com/"
var player_name = GLOBALS.player_email
var score = 0

@onready var http_request = HTTPRequest.new()

func _ready() -> void:
	add_child(http_request)
	http_request.connect("request_completed", self._on_request_completed)

func upload_score(player_name: String, score: int) -> void:
	self.player_name = player_name
	self.score = score
	
	var path = "scores/%s.json" % player_name
	var url = FB_DB_URL + path
	var score_data = {"score": score}
	var json_data = JSON.stringify(score_data)
	var headers = ["Content-Type: application/json"]
	
	var err = http_request.request(url, headers, HTTPClient.METHOD_PUT, json_data)
	if err != OK:
		push_error("Failed to send score to Firebase: %d" % err)
		return

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print("Score uploaded successfully")
	else:
		push_error("Failed to upload score. Response code: %d, Content: %s" % [response_code, body.get_string_from_utf8()])
