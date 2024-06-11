WITH
  combined AS (
    SELECT
      a.player_name,
      a.team_id,
      a.team_abbreviation,
      a.pts -- 0 points means a player played in game without scoring, a null indicates they didn't play
,
      a.min --to determine for sure if a player played a game even without any points
,
      b.home_team_id,
      b.visitor_team_id,
      b.season,
      b.game_id,
      b.home_team_wins,
      b.game_date_est
    FROM
      saismail.nba_game_details_deduped a
      JOIN bootcamp.nba_games b ON a.game_id = b.game_id
  ),
  team_wins AS (
    SELECT
      team_id,
      game_date_est AS game_date,
      CASE
        WHEN team_id = home_team_id
        AND home_team_wins = 1 THEN 1
        WHEN team_id = visitor_team_id
        AND home_team_wins = 0 THEN 1
        ELSE 0
      END AS wins,
      ROW_NUMBER() OVER (
        PARTITION BY
          team_id
        ORDER BY
          game_date_est
      ) AS game_number
    FROM
      combined
  ),
  rolling_wins AS (
    SELECT
      team_id,
      game_date,
      game_number,
      SUM(wins) OVER (
        PARTITION BY
          team_id
        ORDER BY
          game_number ROWS BETWEEN 89 PRECEDING
          AND CURRENT ROW
      ) AS wins_in_90_games
    FROM
      team_wins
  )
SELECT
  team_id,
  MAX(wins_in_90_games) AS max_wins_in_90_games
FROM
  rolling_wins
GROUP BY
  team_id
ORDER BY
  max_wins_in_90_games DESC
LIMIT
  1