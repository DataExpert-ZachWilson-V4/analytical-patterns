CREATE TABLE game_details_dashboard AS
-- Create a new table called game_details_dashboard

WITH combined AS (
    -- Create a common table expression (CTE) called combined
    
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
    WHERE games.home_team_id IS NOT NULL AND games.visitor_team_id IS NOT NULL AND home_team_wins IS NOT NULL AND dedup.team_id IS NOT NULL
    -- Select specific columns from the dedup and games tables and perform some conditional logic to determine the match_won value
)

SELECT
    CASE 
        WHEN GROUPING(player, team) = 0 
            THEN 'player_team'
        WHEN GROUPING(player, season) = 0 
            THEN 'player_season'
        WHEN GROUPING(team) = 0 
        THEN 'team'
    END AS aggregation_level,
    COALESCE(player, 'overall') AS player,
    COALESCE(CAST(season AS VARCHAR), 'overall') AS season,
    COALESCE(team, 'overall') AS team,
    SUM(pts) AS total_points,
    COUNT(DISTINCT match_won) AS total_wins
-- Select specific columns from the combined CTE and perform aggregations using GROUP BY and aggregate functions like SUM and COUNT

FROM
  combined
-- Use the combined CTE as the source for the main query

GROUP BY
  GROUPING SETS ((player, team), (player, season), (team))
-- Group the data based on different combinations of player, team, and season using GROUPING SETS