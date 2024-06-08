
WITH lebron_games AS (
	SELECT *
	FROM bootcamp.nba_game_details
	WHERE player_name='LeBron James'
),
lebron_ranked AS (
	SELECT 
		*, 
		ROW_NUMBER() OVER (PARTITION BY game_id, team_id) as ord
	FROM lebron_games
),
lebron_dedup AS (
	SELECT *
	FROM lebron_ranked
	WHERE ord=1
),
lebron_lagged AS (
	SELECT *, LAG(pts,1) OVER (ORDER BY game_id) as pts_previous
	FROM lebron_dedup
),
lebron_scored_over_10 AS (
	SELECT
		*,
		CASE WHEN pts_previous>10 THEN 1 ELSE 0 END as over10_previous,
		CASE WHEN pts>10 THEN 1 ELSE 0 END as over10_current
	FROM lebron_lagged
),
lebron_streaked AS (
	SELECT 
		*, 
		SUM(CASE WHEN over10_previous<>over10_current THEN 1 ELSE 0 END) OVER (ORDER BY game_id) as streak_idf
	FROM lebron_scored_over_10
	WHERE over10_current = 1
),
lebron_streaked_len AS (
  SELECT streak_idf, COUNT(*) as streak_len
  FROM lebron_streaked
  GROUP BY streak_idf
)

SELECT MAX(streak_len) FROM lebron_streaked_len