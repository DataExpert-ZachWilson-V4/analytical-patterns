WITH
  results AS (
    SELECT
      game_id,
      game_date_est,
      home_team_id AS team_id,
      home_team_wins AS game_won
    FROM
      bootcamp.nba_games
    UNION
    SELECT
      game_id,
      game_date_est,
      visitor_team_id AS team_id,
      CASE
        WHEN home_team_wins = 1 THEN 0
        WHEN home_team_wins = 0 THEN 1
        ELSE NULL
      END AS game_won
    FROM
      bootcamp.nba_games
  ),
  team_information AS (
    SELECT DISTINCT
      team_id,
      team_abbreviation
    FROM
      bootcamp.nba_game_details_dedup
  ),
  combined AS (
    SELECT
      r.*,
      ti.team_abbreviation
    FROM
      results r
      JOIN team_information ti ON ti.team_id = r.team_id
    ORDER BY
      game_id
  ),
  ninty_day_window AS (
    SELECT
      team_abbreviation,
      game_date_est,
      game_id,
      SUM(game_won) OVER (
        PARTITION BY
          team_id
        ORDER BY
          DATE(game_date_est) ROWS BETWEEN 89 PRECEDING
          AND CURRENT ROW
      ) AS wins_last_90_games,
      COUNT(game_date_est) OVER (
        PARTITION BY
          team_id
        ORDER BY
          DATE(game_date_est)
      ) AS game_number
    FROM
      combined
  ),
  FINAL AS (
    SELECT
      team_abbreviation,
      wins_last_90_games,
      dense_rank() OVER (
        ORDER BY
          wins_last_90_games DESC
      ) AS RANK
    FROM
      ninty_day_window
    WHERE
      game_number >= 90
  )
SELECT
  team_abbreviation,
  wins_last_90_games
FROM
  FINAL
WHERE
  RANK = 1

