-- use GROUPING SETS to perform aggregations of the 
-- nba_game_details data. 
-- Create slices that aggregate along the 
-- following combinations of dimensions:
--    player and team
--    player and season
--    team
CREATE OR REPLACE TABLE jimmybrock65656.grouping_sets_nba AS
SELECT
    CASE 
        WHEN GROUPING(gd.player_name, gd.team_abbreviation) = 0 
        THEN 'player_team'
        WHEN GROUPING(gd.player_name, g.season) = 0 
        THEN 'player_season'
        WHEN GROUPING(gd.team_abbreviation) = 0 
        THEN 'team'
    END as aggregation_level,
    -- nulls = Overall
    COALESCE(gd.player_name, 'Overall') AS player,
    -- leave nulls due to grouping sets
    COALESCE(gd.team_abbreviation, 'Overall') AS team,
    COALESCE(CAST(g.season AS VARCHAR), 'Overall') AS season,
    -- total points
    SUM(pts) AS total_points,
    SUM(
     IF(
       (team_id = home_team_id AND home_team_wins = 1)
       OR (team_id = visitor_team_id AND home_team_wins = 0)
     , 1, 0) -- Total wins
     ) AS won_games -- Count won games
-- use deduped data
FROM bootcamp.nba_game_details_dedup AS gd
JOIN bootcamp.nba_games AS g
  ON gd.game_id = g.game_id
GROUP BY 
GROUPING SETS (
  (gd.player_name, gd.team_abbreviation),
  (gd.player_name, g.season),
  (gd.team_abbreviation)
)