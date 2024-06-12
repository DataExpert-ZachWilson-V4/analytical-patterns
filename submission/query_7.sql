 WITH lebron_threshold AS (
     SELECT
         game_date_est,
         CASE WHEN game_dedup.pts > 10 THEN 1 ELSE 0 END AS threshold, -- points higher than 10 from dedup table
         ROW_NUMBER() OVER (ORDER BY game_date_est) AS row_num
     FROM
         bootcamp.nba_game_details_dedup AS game_dedup
     JOIN
         bootcamp.nba_games AS games
     ON
         game_dedup.game_id = games.game_id
     WHERE
         player_name = 'LeBron James'
 ),
 lagged AS (
     SELECT
         row_num,
         row_num - LAG(row_num) OVER (ORDER BY row_num) AS lag_diff -- get the lag diff, order by row_num
     FROM
         lebron_threshold
     WHERE
         threshold = 1  -- get the row num when points are higher than 10 
 ),
 streaks_sum AS (
     SELECT
         row_num,
         SUM(CASE WHEN lag_diff > 1 THEN 1 ELSE 0 END) OVER (ORDER BY row_num) AS total_streaks -- sum of the streaks to get the streak
     FROM
         lagged
 )
 SELECT
     COUNT(*) AS total
 FROM
     streaks_sum
 GROUP BY
     total_streaks
 ORDER BY
     total DESC
 LIMIT 1