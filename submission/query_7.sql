WITH combined AS (
  -- Combine both tables to get info needed for teams and players
  SELECT
    ng.game_id,
    ng.game_date_est,
    ngd.team_id,
    ngd.team_abbreviation AS team_name,
    ngd.player_id,
    ngd.player_name,
    ngd.pts,
    CASE
      WHEN ngd.pts > 10 THEN 1  -- Assign 1 if the player scored more than 10 points
      ELSE 0  -- Assign 0 if the player scored 10 or fewer points
    END AS is_more_than_10_pts  -- Calculated field indicating if the player scored more than 10 points
  FROM bootcamp.nba_games ng
  INNER JOIN bootcamp.nba_game_details_dedup ngd ON ng.game_id = ngd.game_id
  WHERE player_name = 'LeBron James'  -- Filter for LeBron James only
),
ranking AS (
  -- Using row number to divide each streak using the concept of islands and gaps
  SELECT
    *,
    ROW_NUMBER() OVER ( -- Row number partitioned by player name and ordered by game date
      PARTITION BY player_name 
      ORDER BY game_date_est
    ) - ROW_NUMBER() OVER ( -- Row number partitioned by player name and whether points are more than 10, ordered by game date
      PARTITION BY player_name, is_more_than_10_pts 
      ORDER BY game_date_est
    ) AS rnk  -- Calculate rank to identify streaks
  FROM combined
),
streak AS (
  -- Sum all streaks for each player
  SELECT
    player_name,
    rnk,  -- Rank to identify streaks
    SUM(is_more_than_10_pts) AS sum_games_more_than_10  -- Sum of games where points were more than 10 in each streak
  FROM ranking
  GROUP BY player_name, rnk -- Group by player name and rank
)
-- Get maximum streak and the player
SELECT
  MAX_BY(player_name, sum_games_more_than_10) AS player_name, -- Player with the longest streak
  MAX(sum_games_more_than_10) AS sum_games_more_than_10 -- Length of the longest streak
FROM streak
