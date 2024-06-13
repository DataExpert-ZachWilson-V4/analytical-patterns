WITH lebron_james_games AS (
    SELECT 
        g.game_date_est,
        d.*,
        ROW_NUMBER() OVER (PARTITION BY d.game_id, team_id, player_id ORDER BY g.game_date_est) AS row_num_dedup,        --deduplicate rows for game_id,team_id,player_id combination
        ROW_NUMBER() OVER (ORDER BY g.game_date_est) AS row_num,                                                         -- rows ordered by game date
        ROW_NUMBER() OVER (PARTITION BY CASE WHEN pts > 10 THEN 1 ELSE 0 END ORDER BY g.game_date_est) AS streak_groups  --rows with streak of points scored over 10 identified
    FROM bootcamp.nba_game_details d
    JOIN bootcamp.nba_games g ON d.game_id = g.game_id
    WHERE player_name = 'LeBron James'                                                                                     --filter for player name
)
SELECT 
    COUNT(1) OVER (PARTITION BY row_num - streak_groups ORDER BY game_date_est) AS num_games                               --identify rows which are start of a points>10 streak and count such rows
FROM lebron_james_games
WHERE row_num_dedup = 1
ORDER BY num_games DESC
LIMIT 1
