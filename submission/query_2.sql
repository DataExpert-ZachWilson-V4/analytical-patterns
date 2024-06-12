-- Join nba_game_details with nba_games to get all fields in one table
-- Cast data types as needed
-- Results presisted in ovoxo.nba_game_details_grouped to be used in later queries
-- -- Table setup to create ovoxo.nba_game_details_grouped
-- CREATE TABLE ovoxo.nba_game_details_grouped (
--     player_name varchar,
--     team_abbreviation varchar,
--     season integer,
--     total_points integer,
--     total_games_team_won integer,
--     agg_type varchar
-- )
-- WITH (
--   FORMAT = 'PARQUET',
--   PARTITIONING = array['season']
-- )

WITH 
    -- add a row number to each row in nba_game_details to be used for deduping
    nba_game_details_deduped AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) rn 
        FROM bootcamp.nba_game_details
    ),

    combined AS (
        SELECT
            gd.team_abbreviation AS team_abbreviation,
            gd.player_name AS player_name,
            CAST(pts AS DOUBLE) AS m_points,
            g.season AS season,
            CASE 
                WHEN gd.team_id = g.home_team_id AND g.home_team_wins = 1 THEN 1    -- if tean_id is same as home_team_id and home_team_wins is 1, then team won
                WHEN gd.team_id = g.visitor_team_id AND g.home_team_wins = 0 THEN 1 -- if team_id is same as visitor_team_id and home_team_wins is 0, then team won
                ELSE 0
            END AS dim_team_won, -- determines if a team won or lost
           ROW_NUMBER() OVER (PARTITION BY gd.game_id,  gd.team_id) AS rn_team_games -- used to dedupe and get total number of games won by each team
        FROM bootcamp.nba_games g -- used nba_games dataset to get season and determien team win status
        JOIN nba_game_details_deduped gd ON g.game_id = gd.game_id AND gd.rn = 1
    ),

    -- This CTE is used to separately determine the total number of games won by each team
    -- This is done because this metric is not additive on any player related grain.
    -- For this metric to be determined as part of the grouping sets, we have to include game_id which would still keep the data at player_game level and lead to a bigger table
    games_won_by_team AS (
        SELECT team_abbreviation,
            SUM(dim_team_won) AS total_team_wins -- total team wins across multiple games
        FROM combined
        WHERE rn_team_games = 1  -- only include one player record for game and team win
        GROUP BY team_abbreviation
    )

-- Aggregate data, Group by combinations of  player, team, and season
-- agg_type field is used to distinguish between agrregeattions valid for player and team, player and season, and team only
SELECT COALESCE(player_name, '(all_players)') as player_name,
    COALESCE(c.team_abbreviation, '(all_teams)') as team_abbreviation,
    season,
    SUM(m_points) AS total_points,
    CASE 
        WHEN COALESCE(c.team_abbreviation, '(all_teams)') = '(all_teams)' THEN NULL -- the total_gameas_team_won is only relevant for teams
        ELSE MAX(gt.total_team_wins) 
    END AS total_games_team_won,
    CASE 
        WHEN grouping(player_name) = 0 AND grouping(c.team_abbreviation) = 0 and grouping(season) = 1 THEN 'player_team_aggregate' 
        WHEN grouping(player_name) = 0 AND grouping(c.team_abbreviation) = 1 and grouping(season) = 0 THEN 'player_season_aggregate'
        WHEN grouping(player_name) = 1 AND grouping(c.team_abbreviation) = 0 and grouping(season) = 1 THEN 'team_aggregate'
    END AS agg_type
FROM combined c
LEFT JOIN games_won_by_team gt ON c.team_abbreviation = gt.team_abbreviation
GROUP BY 
  GROUPING SETS (
    (player_name, c.team_abbreviation),
    (player_name, season),
    (c.team_abbreviation)
  )