CREATE OR REPLACE TABLE dswills94.nba_games_agg AS
WITH nba_game_details_rn AS (--we have build rankings using row number 
SELECT
	player_id,
	player_name,
	pts,
	team_id,
	team_abbreviation,
	game_id,
	ROW_NUMBER() OVER (PARTITION BY player_id, game_id, team_id
	                   ORDER BY player_id, game_id, team_id
                      ) AS ranked
FROM bootcamp.nba_game_details
),
nba_game_details AS (--we pull the best rank
SELECT
	player_id,
	player_name,
	pts,
	team_id,
	team_abbreviation,
	game_id
FROM nba_game_details_rn
WHERE ranked = 1
),
nba_games_rn AS (--we have to build rankings using row number
SELECT
	game_id,
	season,
	home_team_id,
	visitor_team_id,
	home_team_wins,
	ROW_NUMBER() OVER (PARTITION BY game_id) AS ranked
FROM bootcamp.nba_games
),
nba_games AS (--we pull the best rank
SELECT
	game_id,
	season,
	home_team_id,
	visitor_team_id,
	home_team_wins
FROM nba_games_rn
WHERE ranked = 1 
),
pre_nba_game_agg AS (
SELECT
	COALESCE(CAST(g.season AS VARCHAR), 'blank_season') AS season,
	COALESCE(d.team_abbreviation, 'n/a') AS team,
	COALESCE(d.player_name, 'unknown_player') AS player,
	d.team_id AS team_id,
	d.pts AS pts,
	g.visitor_team_id AS visitor_team_id,
	g.home_team_id AS home_team_id,
	g.home_team_wins AS home_team_wins
FROM nba_game_details d
INNER JOIN nba_games g
ON d.game_id = g.game_id
)
SELECT
	COALESCE(season, '(Final)') AS season,
	COALESCE(player, '(Final)') as player,
	COALESCE(team, '(Final)') as team,
	CASE
		WHEN GROUPING(player, team) = 0 THEN 'player_team'
		WHEN GROUPING(player, season) = 0 THEN 'player_season'
		WHEN GROUPING(team) = 0 THEN 'team'
	END AS agg_tier,
	SUM(pts) as total_player_points,
	SUM(CASE
		WHEN team_id = home_team_id AND home_team_wins = 1 THEN 1
		WHEN team_id = visitor_team_id AND home_team_wins = 0 THEN 1
		ELSE 0
		END) AS total_team_wins
FROM pre_nba_game_agg
GROUP BY
GROUPING SETS (
(player, team),
(player, season),
(team)
)
