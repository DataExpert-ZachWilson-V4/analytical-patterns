CREATE OR REPLACE TABLE adbeyer.nba_grouped_sets AS
SELECT
    CASE 
        WHEN GROUPING(games_details_deduped.player_name, games_details_deduped.team_abbreviation) = 0 THEN 'player_and_team'
        WHEN GROUPING(games_details_deduped.player_name, games.season) = 0 THEN 'player_and_season'
        WHEN GROUPING(games_details_deduped.team_abbreviation) = 0 THEN 'team'
    END as aggregation_level,
    COALESCE(games_details_deduped.player_name, 'Overall') AS player, -- Coalescing to deal when things are grouped past the individual level
    COALESCE(games_details_deduped.team_abbreviation, 'Overall') AS team,
    COALESCE(CAST(games.season AS VARCHAR), 'Overall') AS season,
    SUM(pts) AS total_points,
    SUM(
     IF(
       (team_id = home_team_id AND home_team_wins = 1)
       OR (team_id = visitor_team_id AND home_team_wins = 0)
     , 1, 0) 
     ) AS won_games 
FROM bootcamp.nba_game_details_dedup AS games_details_deduped
JOIN bootcamp.nba_games AS games
  ON games_details_deduped.game_id = games.game_id
GROUP BY GROUPING SETS (
  (games_details_deduped.player_name, games_details_deduped.team_abbreviation),
  (games_details_deduped.player_name, games.season),
  (games_details_deduped.team_abbreviation)
)