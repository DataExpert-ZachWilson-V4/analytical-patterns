-- CREATE TABLE aasimsani0586451.nba_game_stats (
-- 	team VARCHAR,
-- 	player_name VARCHAR,
-- 	season VARCHAR,
-- 	team_wins INT,
-- 	total_points INT
-- )

-- INSERT INTO aasimsani0586451.nba_game_stats

-- De-duplicate the games and get the player details
WITH check_duplicate_games as (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY game_id
			ORDER BY game_date_est DESC
		) as row_num
	FROM bootcamp.nba_games
),
distinct_games as (
	SELECT *
	FROM check_duplicate_games
	WHERE row_num = 1
),

-- Gather the game details by player and do some cleanup
game_and_player_details as (
	SELECT 
		game_details.team_abbreviation as team,
		game_details.player_name,
		-- Nulls are replaced with 0
		COALESCE(game_details.pts, 0) as points,
		-- Since we want to use 'overall' with grouping sets
		CAST(games.season AS VARCHAR) as season,
		-- Needed to determine if the team won
		CASE 
			WHEN game_details.team_id = games.home_team_id THEN 'home'
			WHEN game_details.team_id = games.visitor_team_id THEN 'away'
			ELSE NULL
		END AS game_location,
		CASE
			WHEN games.home_team_wins = 1 THEN 'home'
			ELSE 'away'
		END AS game_location_won
	FROM bootcamp.nba_game_details_dedup as game_details
		INNER JOIN distinct_games as games ON game_details.game_id = games.game_id
),


-- Make the grouping sets
SELECT 
	COALESCE(team, 'overall') as team,
	COALESCE(player_name, 'overall') as player_name,
	COALESCE(season, 'overall') as season,
	SUM(
			CASE
				WHEN (
					game_location = 'home'
					AND game_location_won = 'home'	
				)
				OR (
					game_location = 'away'
					AND game_location_won = 'away'
				) THEN 1
				ELSE 0
			END
		) as team_wins,
	SUM(points) as total_points,
	CASE 
		WHEN GROUPING(player_name, team) = 0 THEN 'player_team'
		WHEN GROUPING(player_name, season) = 0 THEN 'player_season'
		WHEN GROUPING(team) = 0 THEN 'team'
	END AS grouping_type
	FROM game_and_player_details
	GROUP BY GROUPING SETS (
		(player_name, team),
		(player_name, season),
		(team)
	)