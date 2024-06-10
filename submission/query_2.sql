WITH combined AS (
    SELECT
      games.season,
      dedup.player_name AS player,
      dedup.team_abbreviation AS team,
      dedup.pts AS pts,
      CASE
        WHEN games.home_team_id = dedup.team_id AND home_team_wins = 1 THEN games.game_id
        WHEN games.visitor_team_id = dedup.team_id AND home_team_wins = 0 THEN games.game_id
        WHEN home_team_wins IS NULL THEN NULL
        ELSE NULL
      END AS match_won
    FROM
      bootcamp.nba_game_details_dedup AS dedup
      JOIN bootcamp.nba_games AS games ON games.game_id = dedup.game_id
)
SELECT
  COALESCE(player, 'overall') AS player,
  COALESCE(CAST(season AS VARCHAR), 'overall') AS season,
  COALESCE(team, 'overall') AS team,
  SUM(pts) AS total_points,
  COUNT(DISTINCT match_won) AS total_wins
FROM
  combined
GROUP BY
  GROUPING SETS ((player, team), (player, season), (team)) -- slices that aggregate along the following combinations