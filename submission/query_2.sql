WITH nba_game_details_row_number AS (
	SELECT game_id, player_name, team_abbreviation, pts, ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) AS row_number
	FROM bootcamp.nba_game_details
),
nba_game_details_deduped AS (
	SELECT game_id, player_name, team_abbreviation, pts
	FROM nba_game_details_row_number
	WHERE row_number = 1
),
nba_games_row_number AS (
	SELECT game_id, season, ROW_NUMBER() OVER (PARTITION BY game_id) AS row_number
	FROM bootcamp.nba_games
),
nba_games_deduped AS (
	SELECT game_id, season
	FROM nba_games_row_number
	WHERE row_number = 1
)
SELECT player_name,
	team_abbreviation,
	season,
	SUM(pts) AS pts
FROM nba_games_deduped ng
JOIN nba_game_details_deduped ngd ON ngd.game_id = ng.game_id
GROUP BY GROUPING SETS (
	(player_name, team_abbreviation),
	(player_name, season),
	(team_abbreviation)
)