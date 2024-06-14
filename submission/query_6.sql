/*
- Write a query (`query_6`) that uses window functions on `nba_game_details` to answer the question: "What is the most games a single team has won in a given 90-game stretch?"
*/

-- Queries using window functions over()
WITH game_deduped AS (
  SELECT
    game_id,
    team_id,
    team_abbreviation
  FROM
    bootcamp.nba_game_details_dedup
  GROUP BY
    game_id,
    team_id,
    team_abbreviation
),
combined AS (
  SELECT
    games.game_date_est,
    game_deduped.team_id,
    game_deduped.team_abbreviation,
    CASE
      WHEN game_deduped.team_id = games.home_team_id AND games.home_team_wins = 1 THEN 1
      WHEN game_deduped.team_id = games.visitor_team_id AND games.home_team_wins = 0 THEN 1
      ELSE 0
    END AS team_wins
  FROM
    bootcamp.nba_games games
    JOIN game_deduped ON games.game_id = game_deduped.game_id
),
game_stretch_90 AS (
  SELECT
    team_id,
    team_abbreviation,
    SUM(team_wins) OVER (
      PARTITION BY team_id
      ORDER BY game_date_est
      ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ) AS wins
  FROM
    combined
)
SELECT
  team_id,
  team_abbreviation,
  MAX(wins) AS max_wins
FROM
  game_stretch_90
GROUP BY
  team_id,
  team_abbreviation
ORDER BY
  max_wins DESC
LIMIT 1

/*
Result : 80

team_id	    team_abbreviation	max_wins
1610612744	GSW	                80

*/
