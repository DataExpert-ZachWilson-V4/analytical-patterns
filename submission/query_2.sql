-- query 2 Grouping sets to aggregate nba_game_details data 

CREATE OR REPLACE TABLE aayushi.nba_grouping_sets AS
-- CTE to aggregate player performance and team statistics
WITH
    deduped_data AS (
        SELECT 
            ngd.player_name,
            ndg.pts,
            ngd.team_abbreviation AS team_name,
            ng.game_date_est,
            ng.season,
            --calculating whether team won or lost
            CASE 
                WHEN visitor_team_id = ngd.team_id AND home_team_wins = 1 THEN 0
                WHEN visitor_team_id = ngd.team_id AND home_team_wins = 0 THEN 1
            END AS did_win,
            -- using row_number to de-dup the data
            ROW_NUMBER() OVER (PARTITION BY ngd.game_id, ngd.team_id, ngd.player_id order by ng.game_date_est) as rn 
        FROM bootcamp.nba_game_details ngd 
        JOIN bootcamp.nba_games ng 
            ON ngd.game_id = ng.game_id

)

-- Final selection of aggregated data
SELECT
    CASE 
        WHEN GROUPING(player_name, team_name) = 0 then 'player_and_team'  -- Group by player name and team name
        WHEN GROUPING(player_name, season) = 0 then 'player_and_season'   -- Group by player name and season
        WHEN GROUPING(team_name) = 0 then 'team'                          -- Group by team name
    END AS agg_data, 
    COALESCE(player_name, 'overall') as player_name,
    COALESCE(team_name, 'overall') as team,
    COALESCE(cast(season as varchar), 'overall') as season,
    SUM(pts) as points, 
    SUM(did_win) as wins
    from deduped_data 
    where rn = 1
    GROUP BY 
        -- Grouping sets for different levels of aggregation
        GROUPING SETS(                         
            (player_name, team_name),
            (player_name, season),
            (team_name)
        )
