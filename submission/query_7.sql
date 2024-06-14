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
WHERE scored_over_ten_pts = 1
GROUP BY streak_identifier
ORDER BY COUNT(1) DESC