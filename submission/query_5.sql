-- Which team has won the most games?
-- This question doesn't require a GROUPING SETS query.
-- The following simple query should suffice: 

WITH winning_teams AS (
  SELECT
    game_id,
    home_team_id AS team_id
  FROM bootcamp.nba_games
  WHERE home_team_wins = 1
)
SELECT
  team_id,
  COUNT(game_id) AS games_won
FROM
  winning_teams
GROUP BY
  team_id
ORDER BY
  COUNT(game_id) DESC
LIMIT 1