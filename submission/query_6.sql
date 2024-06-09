--Write a query (query_6) that uses window functions on nba_game_details to answer the question: "What is the most games a single team has won in a given 90-game stretch?"
WITH team_wins AS (
  SELECT
    team_id,
    team_abbreviation,
    game_date_est,
    CASE
      WHEN home_team_wins = 1 AND team_id = home_team_id THEN 1
      WHEN home_team_wins = 0 AND team_id = visitor_team_id THEN 1
      ELSE 0
    END AS win
  FROM
    bootcamp.nba_game_details d
    JOIN bootcamp.nba_games g ON d.game_id = g.game_id
),
team_wins_with_row_num AS (
  SELECT
    team_id,
    team_abbreviation,
    game_date_est,
    win,
    ROW_NUMBER() OVER (
      PARTITION BY team_id
      ORDER BY game_date_est
    ) AS game_num
  FROM
    team_wins
),
rolling_win_count AS (
  SELECT
    team_id,
    team_abbreviation,
    game_num,
    SUM(win) OVER (
      PARTITION BY team_id
      ORDER BY game_num
      ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ) AS win_count_90_games
  FROM
    team_wins_with_row_num
)
SELECT
  team_abbreviation,
  MAX(win_count_90_games) AS max_wins_in_90_game_stretch
FROM
  rolling_win_count
GROUP BY
  team_abbreviation
ORDER BY
  max_wins_in_90_game_stretch DESC
LIMIT 1