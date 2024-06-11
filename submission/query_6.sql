WITH nba_game_details_rn AS (
SELECT
	game_id,
	team_id,
	team_abbreviation,
	ROW_NUMBER() OVER (PARTITION BY game_id, team_id
	                   ORDER BY game_id, team_id
	                  ) AS ranked
FROM bootcamp.nba_game_details
ORDER BY game_id
),
nba_game_details AS (
SELECT
	game_id,
	team_id,
	team_abbreviation
FROM nba_game_details_rn
WHERE ranked = 1
),
nba_games_rn AS (
SELECT
	game_id,
	game_date_est,
	visitor_team_id,
	home_team_id,
	home_team_wins,
	ROW_NUMBER() OVER (PARTITION BY game_id
	                   ORDER BY game_id
	                  ) AS ranked
FROM bootcamp.nba_games
ORDER BY game_id
),
nba_games AS (
SELECT
	game_id,
	game_date_est,
	visitor_team_id,
	home_team_id,
	home_team_wins
FROM nba_games_rn
WHERE ranked = 1
),
pre_nba_game_agg AS (
SELECT
	d.game_id,
	g.game_date_est,
	d.team_abbreviation,
	CASE
		WHEN (g.home_team_id = d.team_id) AND g.home_team_wins = 1 THEN 1
		WHEN (g.visitor_team_id = d.team_id) AND g.home_team_wins = 0 THEN 1
		ELSE 0
	END AS games_won
FROM nba_game_details d
INNER JOIN nba_games g
ON d.game_id = g.game_id
),
most_wins AS (
SELECT
	game_date_est,
	team_abbreviation AS team,
	SUM(games_won) OVER (PARTITION BY team_abbreviation
	                     ORDER BY game_date_est
	                     ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
	                    ) AS total_90days
FROM pre_nba_game_agg
)
SELECT
	team,
	MAX(total_90days) AS max_90days
FROM most_wins
GROUP BY team
ORDER BY max_90days DESC
