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
player_score_data as (
	SELECT game_details.player_name,
		CASE
			WHEN COALESCE(game_details.pts, 0) > 10 THEN 1
			ELSE 0
		END AS player_scored_10_or_more,
		games.game_date_est
	FROM bootcamp.nba_game_details_dedup as game_details
		INNER JOIN distinct_games as games ON game_details.game_id = games.game_id
	WHERE game_details.player_name = 'LeBron James'
),

-- Use LAG to create a streak identifier
prev_games as (
	SELECT *,
		LAG(player_scored_10_or_more, 1) OVER (
			PARTITION BY player_name
			ORDER BY game_date_est ASC
		) as previous_game_scored_10_or_more
	FROM player_score_data
),
streaks as (
	SELECT *,
		-- Streak check
		SUM(
			IF(
				player_scored_10_or_more = 1
				AND NOT previous_game_scored_10_or_more = 1,
				1,
				0
			)
		) OVER (
			PARTITION BY player_name
			ORDER BY game_date_est ASC
		) as streak
	FROM prev_games
)

-- Get longest streak length for LeBron James
SELECT player_name,
	MAX(COUNT(*)) OVER (PARTITION BY player_name, streak) as longest_streak
FROM streaks
WHERE player_scored_10_or_more = 1
GROUP BY player_name,
	streak
ORDER BY longest_streak DESC
LIMIT 1