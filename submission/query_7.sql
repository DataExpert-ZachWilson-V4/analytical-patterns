--Again, the nba_game_details and nba_games tables need to be deduped. Since we only want points scored for each game by LeBron James,
--it makes sense to join these tables at the beginning and dedupe the result set.
--This query utilizes the same streak logic which can be used to track state changes for a full load of a Type 2 SCD.
--Here the streak_identifier identifies streaks where LeBron either scored above ten points in each game, or scored ten points or fewer in each game.
--The highest number of games in a particular streak where scored_over_ten_pts = 1 identifies the number of games in a row in which LeBron scored over ten points.
WITH lebron_nba_game_details_deduped AS (
	SELECT DISTINCT ng.game_date_est,
		ngd.pts		
	FROM bootcamp.nba_game_details ngd
		JOIN bootcamp.nba_games ng ON ngd.game_id = ng.game_id
	WHERE player_name = 'LeBron James'
),
game_results AS (
	SELECT game_date_est,
		CASE WHEN pts > 10 THEN 1 ELSE 0 END AS scored_over_ten_pts
	FROM lebron_nba_game_details_deduped
), 
lagged AS (
	SELECT game_date_est,
		scored_over_ten_pts,
		LAG(scored_over_ten_pts, 1, 0) OVER (ORDER BY game_date_est) AS scored_over_ten_pts_lagged
	FROM game_results
),
streaks AS (
	SELECT game_date_est,
		scored_over_ten_pts,
		SUM(CASE WHEN scored_over_ten_pts <> scored_over_ten_pts_lagged THEN 1 ELSE 0 END) OVER (ORDER BY game_date_est) AS streak_identifier
	FROM lagged 
)
SELECT COUNT(1) AS number_of_games
FROM streaks
WHERE scored_over_ten_pts = 1		--Capture streaks where LeBron scored over ten points, not where he scored ten points or less
GROUP BY streak_identifier
ORDER BY COUNT(1) DESC
LIMIT 1 