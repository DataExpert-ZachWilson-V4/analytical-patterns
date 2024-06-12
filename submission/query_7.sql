WITH nba_game_details_rn AS (
SELECT
	game_id,
	team_id,
	team_abbreviation,
	player_id,
	player_name,
	pts,
	ROW_NUMBER() OVER (PARTITION BY player_id, game_id, team_id
	                   ORDER BY player_id, game_id, team_id
	                  ) AS ranked
FROM bootcamp.nba_game_details
),
nba_game_details AS (
SELECT
	game_id,
	team_id,
	team_abbreviation,
	player_id,
	player_name,
	pts
FROM nba_game_details_rn
WHERE ranked = 1
),
nba_games_rn AS (
SELECT
	game_id,
	game_date_est,
	ROW_NUMBER() OVER (PARTITION BY game_id
	                   ORDER BY game_id
	                  ) AS ranked
FROM bootcamp.nba_games
),
nba_games AS (
SELECT
	game_id,
	game_date_est
FROM nba_games_rn
WHERE ranked = 1
),
pre_nba_game_agg AS (
SELECT
	d.player_name,
	g.game_date_est,
	d.pts,
	CASE
		WHEN d.pts > 10.0 THEN 1 ELSE 0 --prompt is asking for at least 10 points a game
	END AS pts_level
FROM nba_game_details d
INNER JOIN nba_games g
ON d.game_id = g.game_id
WHERE d.player_name = 'LeBron James'
),
streaked AS (
SELECT
	player_name,
	game_date_est,
	pts_level,
	SUM(CASE WHEN pts_level = 0 THEN 1 ELSE 0 END) OVER (ORDER BY game_date_est) AS counts --have to manage pts less than 0
FROM pre_nba_game_agg
),
calculated_streak AS (
SELECT
	player_name,
	game_date_est,
	pts_level,
	SUM(CASE WHEN pts_level = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY counts ORDER BY game_date_est) AS tenpt_streak_calc --where we sum up the actual 10 point streaks
FROM streaked
)
SELECT
	MAX(tenpt_streak_calc) AS Ten_Point_Streak
FROM calculated_streak
