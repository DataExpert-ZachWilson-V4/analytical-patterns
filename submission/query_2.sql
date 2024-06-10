CREATE
OR REPLACE TABLE ebrunt.game_details_dashboard AS
WITH
  games AS (
    SELECT
      game_id,
      home_team_id,
      visitor_team_id,
      season,
      home_team_wins
    FROM
      bootcamp.nba_games
  ),
  combined AS (
    SELECT
      games.season,
      nba_game_details_dedup.team_abbreviation AS team,
      nba_game_details_dedup.player_name AS player,
      nba_game_details_dedup.pts AS points,
      CASE
        WHEN games.home_team_id = nba_game_details_dedup.team_id
        AND home_team_wins = 1 THEN games.game_id
        WHEN games.visitor_team_id = nba_game_details_dedup.team_id
        AND home_team_wins = 0 THEN games.game_id
        ELSE NULL
      END AS won
    FROM
      bootcamp.nba_game_details_dedup
      JOIN games ON games.game_id = nba_game_details_dedup.game_id
  )
SELECT
  COALESCE(player, 'overall') AS player,
  COALESCE(CAST(season AS varchar), 'overall') AS season,
  COALESCE(team, 'overall') AS team,
  sum(points) AS total_points,
  count(DISTINCT won) AS total_wins
FROM
  combined
GROUP BY
  GROUPING SETS ((player, team), (player, season), (team))
