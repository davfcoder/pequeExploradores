extends Node

const TEXT := {
	"es": {
		"play": "Jugar",
		"parents": "Para Padres",
		"settings": "Configuración",
		"close": "Cerrar",
		"back": "Volver",
		"exit": "Salir",
		"music_on": "Música: Activada",
		"music_off": "Música: Desactivada",
		"fullscreen": "Pantalla completa",
		"exit_fullscreen": "Salir pantalla completa",
		"language_locked": "Idioma bloqueado",
		"language_es": "Idioma: Español",
		"language_en": "Idioma: English",

		"confirm": "Confirmar",
		"delete_confirm": "¿Seguro que deseas borrar todos los datos?",
		"yes_delete": "Sí, borrar",
		"cancel": "Cancelar",

		"progress_report": "Reporte de Aprendizaje",
		"unlock_bilingual": "Desbloquear Modo Bilingüe",
		"bilingual_unlocked": "Modo bilingüe desbloqueado",
		"delete_all": "Borrar todos los datos",
		"total_time": "Tiempo total",

		"world_colores": "Valle de los Colores",
		"world_numeros": "Isla de los Números",
		"world_animales": "Mundo de los Animales",
		"world_formas": "Ciudad de las Formas",

		"lumi_menu": "Hola, soy Lumi. ¿A dónde vamos hoy?",
		"lumi_select_world": "¿A qué mundo vamos a jugar hoy?",
		"correct": "¡Correcto!",
		"try_again": "No pasa nada, intenta otra vez",
		"hint": "Mira con atención. Te daré una pista",
		"rest": "Muy bien. Es hora de descansar. Volvemos pronto",
		"completed": "¡Lo lograste! ¡Eres increíble!",
		"drag_to_shadow": "Llévala hasta la silueta",

		"touch_color": "Toca el color: {name}",
		"find_same_color": "Encuentra el color igual a la burbuja",
		"touch_repeated_color": "Toca el color que aparece dos veces",

		"count_points": "Cuenta los puntos y toca el número correcto",
		"touch_number": "Toca el número: {name}",
		"touch_card_points": "Toca la tarjeta que tiene {count} puntos",

		"animal_sound": "¿Qué animal hace ese sonido? ¡Tócalo!",
		"touch_animal": "Toca al animal: {name}",
		"animal_shadow": "¿A qué animal pertenece esta silueta?",
		"animal_habitat": "¿Dónde vive {name}?",

		"touch_shape": "Toca la figura: {name}",
		"drag_shape": "Arrastra la figura a su silueta ✋",
		"touch_two_shapes": "Toca las dos figuras que son: {name}",
		"touch_same_shapes": "Toca las dos figuras iguales",
		
		"choose_world": "Elige un mundo",
		"repeat": "Repetir",
	
		"continue": "Continuar",
		"parent_gate": "Para acceder, resuelve:\n{question}",
		"incorrect_try_again": "Incorrecto. Intenta de nuevo.",
		
		"shape_classification_hint": "Mira con atención. Toca las dos figuras iguales"
	},

	"en": {
		"play": "Play",
		"parents": "For Parents",
		"settings": "Settings",
		"close": "Close",
		"back": "Back",
		"exit": "Exit",
		"music_on": "Music: On",
		"music_off": "Music: Off",
		"fullscreen": "Fullscreen",
		"exit_fullscreen": "Exit Fullscreen",
		"language_locked": "Language locked",
		"language_es": "Language: Spanish",
		"language_en": "Language: English",

		"confirm": "Confirm",
		"delete_confirm": "Are you sure you want to delete all data?",
		"yes_delete": "Yes, delete",
		"cancel": "Cancel",

		"progress_report": "Learning Report",
		"unlock_bilingual": "Unlock Bilingual Mode",
		"bilingual_unlocked": "Bilingual mode unlocked",
		"delete_all": "Delete all data",
		"total_time": "Total time",

		"world_colores": "Color Valley",
		"world_numeros": "Number Island",
		"world_animales": "Animal World",
		"world_formas": "Shape City",

		"lumi_menu": "Hi, I am Lumi. Where should we go today?",
		"lumi_select_world": "Which world should we play today?",
		"correct": "Correct!",
		"try_again": "That's okay, try again",
		"hint": "Look carefully. I will give you a hint",
		"rest": "Great job. It is time to rest. See you soon",
		"completed": "You did it! You are amazing!",
		"drag_to_shadow": "Drag it to the shadow",

		"touch_color": "Touch the color: {name}",
		"find_same_color": "Find the color that matches the bubble",
		"touch_repeated_color": "Touch the color that appears twice",

		"count_points": "Count the dots and touch the correct number",
		"touch_number": "Touch the number: {name}",
		"touch_card_points": "Touch the card with {count} dots",

		"animal_sound": "Which animal makes that sound? Touch it!",
		"touch_animal": "Touch the animal: {name}",
		"animal_shadow": "Which animal belongs to this shadow?",
		"animal_habitat": "Where does {name} live?",

		"touch_shape": "Touch the shape: {name}",
		"drag_shape": "Drag the shape to its shadow ✋",
		"touch_two_shapes": "Touch the two shapes that are: {name}",
		"touch_same_shapes": "Touch the two matching shapes",
		
		"choose_world": "Choose a world",
		"repeat": "Repeat",
		
		"continue": "Continue",
		"parent_gate": "To enter, solve:\n{question}",
		"incorrect_try_again": "Incorrect. Try again.",
		
		"shape_classification_hint": "Look carefully. Touch the two matching shapes"
	}
}

func t(key: String, params: Dictionary = {}) -> String:
	var lang := GameState.idioma_actual
	var texto: String = TEXT.get(lang, TEXT["es"]).get(key, TEXT["es"].get(key, key))

	for param_key in params.keys():
		texto = texto.replace("{" + str(param_key) + "}", str(params[param_key]))

	return texto
