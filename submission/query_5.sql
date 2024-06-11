WITH game_dates AS (
  SELECT 
    game_id,
    CASE
      WHEN home_team_wins = 1 THEN home_team_id
      ELSE visitor_team_id
    END AS winning_team_id,
    season AS g_season
  FROM bootcamp.nba_games
),

team_wins AS (
  SELECT
    winning_team_id,
    COUNT(*) AS total_wins
  FROM game_dates
  GROUP BY winning_team_id
),

ranked_team_wins AS (
  SELECT
    winning_team_id,
    total_wins,
    ROW_NUMBER() OVER (ORDER BY total_wins DESC) AS rank
  FROM team_wins
)

SELECT 
  winning_team_id,
  total_wins,
  rank
FROM ranked_team_wins
ORDER BY rank ASC
