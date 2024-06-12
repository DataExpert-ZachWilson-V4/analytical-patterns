CREATE OR REPLACE TABLE grouping_sets AS
-- CTE to aggregate player performance and team statistics
WITH combined AS (
    -- Select and aggregate the relevant columns
    SELECT 
        player_name,  -- Player's name
        COALESCE(team_city, 'N/A') AS team_city,  -- Team city or 'N/A' if null
        season,  -- Season year
        SUM(a.pts) AS points,  -- Total points scored by the player
        SUM(
            CASE
                -- Increment win count if the player's team won the game
                WHEN (a.team_id = b.home_team_id AND home_team_wins = 1) OR
                     (a.team_id = b.visitor_team_id AND home_team_wins = 0) THEN 1
                ELSE 0
            END
        ) AS total_games_won  -- Total games won by the player's team
    FROM 
        bootcamp.nba_game_details_dedup AS a  -- Game details table
    JOIN
        bootcamp.nba_games AS b  -- Games table
    ON 
        a.game_id = b.game_id  -- Join on game ID
    GROUP BY
        -- Grouping sets for different levels of aggregation
        GROUPING SETS (
            (player_name, team_city),  -- Group by player name and team city
            (player_name, season),  -- Group by player name and season
            (team_city)  -- Group by team city
        )
)
-- Final selection of aggregated data
SELECT
    player_name AS player,  -- Rename player_name to player
    team_city AS team,  -- Rename team_city to team
    season,  -- Season year
    points,  -- Total points scored by the player
    total_games_won  -- Total games won by the player's team
FROM
    combined