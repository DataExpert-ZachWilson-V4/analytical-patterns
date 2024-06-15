WITH
  nba_game_details_deduped AS (
    SELECT DISTINCT
      game_id,
      team_id,
      team_abbreviation
    FROM
      bootcamp.nba_game_details
  ),
  nba_games_deduped AS (
    SELECT DISTINCT
      game_id,
      team_id_home,
      home_team_wins,
      game_date_est
    FROM
      bootcamp.nba_games
  ),
  winning_team AS (
    SELECT
      gd.team_id,
      gd.game_id,
      gd.team_abbreviation,
      g.game_date_est,
      CASE
        WHEN gd.team_id = g.team_id_home THEN g.home_team_wins
        ELSE 1 - g.home_team_wins
      END AS win
    FROM
      nba_game_details_deduped gd
      JOIN nba_games_deduped g ON gd.game_id = g.game_id
  ),
  cummulative_wins_cte AS (
    SELECT
      team_id,
      game_id,
      team_abbreviation,
      game_date_est,
      SUM(win) OVER (
        PARTITION BY
          team_id
        ORDER BY
          game_date_est ROWS BETWEEN 89 PRECEDING
          AND CURRENT ROW
      ) AS rolling_90_game_wins
    FROM
      winning_team
  ),
  max_rolling_wins AS (
    SELECT
      team_id,
      team_abbreviation,
      MAX(rolling_90_game_wins) AS max_wins_over_90_games
    FROM
      cummulative_wins_cte
    GROUP BY
      team_id,
      team_abbreviation
  )
SELECT
  team_abbreviation,
  max_wins_over_90_games
FROM
  max_rolling_wins
ORDER BY
  max_wins_over_90_games DESC
LIMIT
  1
