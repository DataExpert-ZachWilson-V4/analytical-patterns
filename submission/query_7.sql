--Write a query (query_7) that uses window functions on nba_game_details to answer the question: "How many games in a row did LeBron James score over 10 points a game?"
WITH player_game_details AS (
  SELECT 
    *,
    ROW_NUMBER() OVER(PARTITION BY game_id, team_id, player_id) AS detail_rn
  FROM bootcamp.nba_game_details
)

,game_dates AS (
  SELECT 
    game_date_est,
    game_id,
    ROW_NUMBER() OVER(PARTITION BY game_id ORDER BY game_date_est DESC) AS game_rn
  FROM bootcamp.nba_games
)

,lebron_scoring_data AS (
  SELECT
    details.player_name,
    CASE 
      WHEN COALESCE(pts, 0) > 10 THEN 1
      ELSE 0
    END AS current_game_score,
    games.game_date_est
  FROM player_game_details AS details
  INNER JOIN game_dates AS games 
  ON details.game_id = games.game_id
  WHERE details.player_name = 'LeBron James' 
  AND details.detail_rn = 1 
  AND games.game_rn = 1
)

,previous_game_scores AS (
  SELECT *,
    LAG(current_game_score, 1) OVER (ORDER BY game_date_est) AS previous_game_score
  FROM lebron_scoring_data
)

,streak_identification AS (
  SELECT *,
    SUM(CASE WHEN previous_game_score = current_game_score THEN 0 ELSE 1 END) OVER (ORDER BY game_date_est) AS streak_identifier
  FROM previous_game_scores
)

,streak_scores AS (
  SELECT *,
    SUM(current_game_score) OVER(PARTITION BY streak_identifier ORDER BY game_date_est) AS max_games_10_score
  FROM streak_identification
  ORDER BY game_date_est
)

SELECT 
  player_name,
  game_date_est,
  MAX(max_games_10_score) AS total_games_10_score
FROM streak_scores 
GROUP BY player_name, game_date_est
ORDER BY total_games_10_score DESC
LIMIT 1