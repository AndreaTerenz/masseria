extends Node
class_name Global

static var italian_names = [
	"Alessandro", "Andrea", "Antonio", "Bruno", "Carlo", "Cristiano", "Domenico", "Enrico", "Fabio", "Federico", 
	"Francesco", "Gabriele", "Gianluca", "Giorgio", "Giovanni", "Giuseppe", "Leonardo", "Lorenzo", "Luca", "Marco", 
	"Mario", "Matteo", "Michele", "Nicola", "Paolo", "Pietro", "Roberto", "Salvatore", "Simone", "Stefano", 
	"Tommaso", "Vincenzo", "Riccardo", "Giulio", "Davide", "Edoardo", "Alberto", "Claudio", "Daniele", "Emanuele",
	"Alessandra", "Alice", "Anna", "Arianna", "Barbara", "Beatrice", "Bianca", "Camilla", "Carlotta", "Caterina", 
	"Chiara", "Cristina", "Daniela", "Elena", "Elisabetta", "Emma", "Federica", "Francesca", "Gabriella", "Ginevra", 
	"Giulia", "Ilaria", "Laura", "Leonora", "Livia", "Lucrezia", "Lucia", "Maria", "Martina", "Michela", "Monica", 
	"Nicole", "Paola", "Sara", "Serena", "Silvia", "Sofia", "Stefania", "Valentina", "Vittoria", "Veronica",
	"Andrea", "Gabriele", "Nicola", "Samuele", "Sasha", "Luca", "Elia", "Gianni"]

const GAME_SPEED = 2

func _ready() -> void:
	seed(42)
	italian_names.shuffle()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("db_quit"):
		get_tree().quit()
