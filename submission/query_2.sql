/*
Write a query (query_2) that uses GROUPING SETS to perform aggregations of the 
nba_game_details data. Create slices that aggregate along the following 
combinations of dimensions:

player and team
player and season
team
*/

CREATE OR REPLACE TABLE danieldavid.nba_game_details_grouped AS
-- dedupe combined data from games and game details
WITH nba_game_details_combined AS (
    SELECT 
		*, 
		CASE WHEN visitor_team_id = gd.team_id AND home_team_wins = 1 THEN 0
			WHEN visitor_team_id = gd.team_id AND home_team_wins = 0 THEN 1
			ELSE g.home_team_wins
		END AS game_won,
		ROW_NUMBER() OVER(
			PARTITION BY gd.game_id, gd.team_id, player_id ORDER BY g.game_date_est) AS row_num
	FROM bootcamp.nba_game_details gd
	INNER JOIN bootcamp.nba_games g
		ON gd.game_id = g.game_id AND gd.team_id = g.home_team_id
)
-- set grouping sets for different levels of aggregation 
SELECT
	CASE WHEN GROUPING(player_name, team_abbreviation) = 0 THEN 'player_and_team'
		WHEN GROUPING(player_name, season) = 0 THEN 'player_and_season'
		WHEN GROUPING(team_abbreviation) = 0 THEN 'team'
	END as aggregation_level,
	COALESCE(player_name, 'overall') as player_name,
	COALESCE(team_abbreviation, 'overall') as team_abbreviation,
	COALESCE(CAST(season AS VARCHAR), 'overall') as season,
	SUM(pts) AS total_points, 
	SUM(game_won) AS games_won
FROM nba_game_details_combined
WHERE row_num = 1
GROUP BY GROUPING SETS (
	(player_name, team_abbreviation),
	(player_name, season),
	(team_abbreviation)
)