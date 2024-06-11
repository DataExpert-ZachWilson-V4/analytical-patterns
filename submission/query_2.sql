-- Create or replace table raj.nba_games_grouping
Create or replace table raj.nba_games_grouping AS
WITH games_grouping AS (
    SELECT  
        -- Select columns for grouping
        ng.game_date_est,
        ngd.player_name,
        ngd.team_abbreviation AS team,
        ng.season,
        -- Calculate total player points
        SUM(ngd.pts) AS total_player_points,
        -- Calculate total wins based on team performance in games
        SUM(
            CASE 
                WHEN ngd.team_id = ng.home_team_id AND ng.home_team_wins = 1 THEN 1
                WHEN ngd.team_id = ng.visitor_team_id AND ng.home_team_wins = 0 THEN 1
                ELSE 0 
            END
        ) AS total_win,
        -- Row number for each game, team, and player combination
        ROW_NUMBER() OVER (PARTITION BY ngd.game_id, ngd.team_id, ngd.player_id ORDER BY ng.game_date_est) AS rn
    FROM 
        bootcamp.nba_game_details ngd
    JOIN 
        bootcamp.nba_games ng 
    ON 
        ngd.game_id = ng.game_id
    GROUP BY 
        -- Grouping columns
        ng.game_date_est, ngd.player_name, ngd.team_abbreviation, ng.season, ngd.game_id, ngd.team_id, ngd.player_id
)

-- Select aggregated data based on different aggregation levels
SELECT 
    CASE 
        -- Determine aggregation level based on grouping
        WHEN GROUPING(player_name) = 0 AND GROUPING(team) = 0 THEN 'player_plus_team'
        WHEN GROUPING(player_name) = 0 AND GROUPING(season) = 0 THEN 'player_plus_season'
        WHEN GROUPING(team) = 0 THEN 'team'
        ELSE 'Overall'
    END AS Agg_Level,
    COALESCE(player_name, 'Overall') AS player_name,
    COALESCE(team, 'Overall') AS team,
    COALESCE(CAST(season AS VARCHAR), 'Overall') AS season,
    -- Aggregate total player points and wins
    SUM(total_player_points) AS total_player_points,
    SUM(total_win) AS total_win
FROM 
    games_grouping
WHERE 
    rn = 1 -- Consider only the first row for each game, team, and player combination
GROUP BY 
    -- Grouping sets for different aggregation levels
    GROUPING SETS (
        (player_name, team),
        (player_name, season),
        (team)
    )