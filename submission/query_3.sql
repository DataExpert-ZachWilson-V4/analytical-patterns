-- Build the game data as CTE
WITH data AS (
    SELECT
        COALESCE(gd.player_name, 'N/A') AS player_name,
        coalesce(gd.team_abbreviation, 'N/A') AS team,
        coalesce(g.season, 0) AS season,
        gd.pts,
        g.visitor_team_id,
        gd.team_id,
        g.home_team_wins,
        g.game_id
    FROM bootcamp.nba_game_details gd
    JOIN bootcamp.nba_games g ON g.game_id = gd.game_id  
),
aggr as (
    SELECT
        -- The Player Name
        coalesce(player_name, '(overall)') AS player_name,
        -- The Team Name 
        coalesce(team, '(overall)') AS team,
        -- Season
        coalesce(season, -1) AS season,
        -- Total Points
        SUM(pts) AS total_pts,
            -- Total team wins
        SUM(
            CASE 
                WHEN visitor_team_id = team_id AND home_team_wins = 1 THEN 0
                WHEN visitor_team_id = team_id AND home_team_wins = 0 THEN 1
                ELSE home_team_wins
            END
        ) AS total_team_wins
    FROM data
    GROUP BY GROUPING SETS (
        -- Grouping sets to get the aggregates
        (player_name, team),
        (player_name, season),
        (team)
    )
)
SELECT 
    player_name, 
    team, 
    total_pts
FROM aggr
WHERE player_name <> '(overall)' -- Make sure, its a player and not grouping set aggregate
    AND team <> '(overall)' -- Make sure its a team  and not grouping set aggregate
ORDER BY total_pts DESC -- Sort of highest points at the top
LIMIT 1 -- Get the top 1 player only
