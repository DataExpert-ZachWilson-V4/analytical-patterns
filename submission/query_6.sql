--"What is the most games a single team has won in a given 90-game stretch?"

WITH
 nba_game_details_dedup AS (
   SELECT game_id,
     team_id,
     team_abbreviation
   from bootcamp.nba_game_details_dedup
   group by 
   game_id, 
   team_id, 
   team_abbreviation
 ),
combined AS (
  SELECT
    g.game_date_est,
    gd.team_id,
    gd.team_abbreviation,
    CASE
      WHEN gd.team_id = home_team_id
      AND home_team_wins = 1 THEN 1
      WHEN gd.team_id = visitor_team_id
      AND home_team_wins = 0 THEN 1
      ELSE 0
    END AS team_wins
  FROM
    bootcamp.nba_games g
    JOIN nba_game_details_dedup gd ON g.game_id = gd.game_id),
    
 wins_over_90 AS (
   SELECT team_id,
     team_abbreviation,
     SUM(team_wins) OVER (PARTITION BY team_id ORDER BY game_date_est ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ) AS wins
    FROM combined
  )
    
 SELECT MAX_BY(team_id, wins) AS team_id,
   MAX_BY(team_abbreviation, wins) as team_abbreviation,
   MAX(wins) as max_wins
    FROM wins_over_90
