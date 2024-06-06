CREATE OR REPLACE TABLE jsgomez14.grouping_sets_hw5 AS
SELECT
    COALESCE(GD.player_name, 'Overall') AS player, -- Nulls means overall.
    COALESCE(GD.team_abbreviation, 'Overall') AS team,
    COALESCE(CAST(G.season AS VARCHAR), 'Overall') AS season,
    SUM(pts) AS total_points, -- Total points
    AVG(pts) AS avg_points,
    MIN(pts) AS min_points,
    MAX(pts) AS max_points,
    SUM(
     IF(
       (team_id = home_team_id AND home_team_wins = 1)
       OR (team_id = visitor_team_id AND home_team_wins = 0)
     , 1, 0)
     ) AS won_games -- Count won games
FROM bootcamp.nba_game_details_dedup AS GD -- Using dedduped data.
JOIN bootcamp.nba_games AS G
  ON GD.game_id = G.game_id
GROUP BY GROUPING SETS (
  (GD.player_name, GD.team_abbreviation),
  (GD.player_name, G.season),
  (GD.team_abbreviation)
) -- Grouping sets asked in the homework.