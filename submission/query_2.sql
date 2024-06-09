CREATE OR REPLACE TABLE bgar.nba_grouping_sets AS (
WITH deduped_games as (
    SELECT
        game_id,
        home_team_id,
        visitor_team_id,
        MAX(home_team_wins) as home_team_wins,
        MAX(season) as season
    FROM bootcamp.nba_games
    GROUP BY 1, 2, 3
)
SELECT
    CASE
        WHEN grouping (player_id, player_name, team_id) = 0 THEN 'player and team'
        WHEN grouping (player_id, player_name, season) = 0 THEN 'player and season'
        WHEN grouping (team_id) = 0 THEN 'team only'
    END AS level_id,
    player_id,
    player_name,
    team_id,
    team_abbreviation,
    season,
    SUM(pts) as total_points,
    SUM(CASE
            WHEN team_id = home_team_id AND home_team_wins = 1 THEN 1
            WHEN team_id = visitor_team_id AND home_team_wins = 0 THEN 1
            ELSE 0
        END
        ) as n_wins
FROM bootcamp.nba_game_details_dedup as dd
INNER JOIN deduped_games dg
ON dd.game_id = dg.game_id
GROUP BY GROUPING SETS ((player_id, player_name, team_id, team_abbreviation), (player_id, player_name, season), (team_id, team_abbreviation))
)
