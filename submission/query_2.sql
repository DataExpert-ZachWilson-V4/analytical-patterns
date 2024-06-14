/*
Write a query (`query_2`) that uses `GROUPING SETS` to perform aggregations of the `nba_game_details` data. Create slices that aggregate along the following combinations of dimensions:
  - player and team
  - player and season
  - team

*/

-- CTAS to create a dataset for dashboard analytics
CREATE OR REPLACE TABLE harathi.nba_games_details_board AS
SELECT
    CASE 
        WHEN GROUPING(games_details_deduped.player_name) = 0 AND GROUPING(games_details_deduped.team_abbreviation) = 0 THEN 'player_and_team'
        WHEN GROUPING(games_details_deduped.player_name) = 0 AND GROUPING(games.season) = 0 THEN 'player_and_season'
        WHEN GROUPING(games_details_deduped.team_abbreviation) = 0 THEN 'team'
        ELSE 'Overall'
    END as aggregation_level,
    COALESCE(games_details_deduped.player_name, 'Overall') AS player, 
    COALESCE(games_details_deduped.team_abbreviation, 'Overall') AS team,
    COALESCE(CAST(games.season AS VARCHAR), 'Overall') AS season,
    SUM(games_details_deduped.pts) AS total_points,
    SUM(
        CASE 
            WHEN games_details_deduped.team_id = games.home_team_id AND games.home_team_wins = 1 THEN 1
            WHEN games_details_deduped.team_id = games.visitor_team_id AND games.home_team_wins = 0 THEN 1
            ELSE 0
        END
    ) AS won_games 
FROM bootcamp.nba_game_details_dedup AS games_details_deduped
JOIN bootcamp.nba_games AS games
  ON games_details_deduped.game_id = games.game_id
GROUP BY GROUPING SETS (
  (games_details_deduped.player_name, games_details_deduped.team_abbreviation),
  (games_details_deduped.player_name, games.season),
  (games_details_deduped.team_abbreviation)
)

-- 18729 rows
