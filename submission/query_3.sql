-- This query calculates total points scored in NBA games, providing subtotals and overall totals.

WITH
    -- Combine game details with game metadata, adding season information
    game_details_cte AS (
        SELECT
            ngd.*,
            ng.season
        FROM
            bootcamp.nba_game_details_dedup ngd -- Using pre-deduped table that exists in bootcamp schema
            INNER JOIN bootcamp.nba_games ng ON ngd.game_id = ng.game_id
    ),
    
    -- Aggregate total points and handle nulls for comprehensive dashboard data
    nba_game_details_dashboard AS (
        SELECT
            COALESCE(player_name, 'Overall') AS player,
            COALESCE(team_abbreviation, 'Overall') AS team,
            COALESCE(CAST(season AS VARCHAR), 'Overall') AS season,
            
            -- Sum points, treating nulls as 0
            SUM(
                CASE
                    WHEN pts IS NULL THEN 0
                    ELSE pts
                END
            ) AS total_points
        FROM
            game_details_cte
        GROUP BY
            -- Grouping sets to create subtotals for each player, team, and season
            GROUPING SETS (
                (player_name, team_abbreviation),
                (player_name, season),
                (team_abbreviation)
            )
    ),
    
    -- Filter to get player-team combinations excluding overall totals
    nba_game_details_dashboard_player_team_total AS (
        SELECT
            *
        FROM
            nba_game_details_dashboard
        WHERE
            team <> 'Overall'
            AND player <> 'Overall'
            AND season = 'Overall'
    )
    
-- Select the player with the highest total points and the corresponding team
SELECT
    player,
    MAX(total_points) AS max_total_points,
    MAX_BY(team, total_points) AS team
FROM
    nba_game_details_dashboard_player_team_total
GROUP BY
    player
ORDER BY
    max_total_points DESC
LIMIT
    1;
