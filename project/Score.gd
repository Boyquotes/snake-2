extends Node2D

func update_score(snake_length):
	$ScoreLabel.text = str(snake_length)
	if (snake_length > int($HighScore.text)):
		$HighScore.text = str(snake_length)
