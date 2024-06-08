WITH grouped_data AS(
    SELECT d.game_id,
        d.player_name,
        d.team_abbreviation,
        g.season,
        SUM(d.pts) as total_points,
        -- get the winner team for that game, player_name records
        MAX(
            CASE
                WHEN g.home_team_id = d.team_id
                AND g.home_team_wins = 1 THEN d.team_abbreviation
                WHEN g.visitor_team_id = d.team_id
                AND g.home_team_wins = 0 THEN d.team_abbreviation
            END
        ) AS winner
    FROM bootcamp.nba_game_details d
        JOIN bootcamp.nba_games g ON d.game_id = g.game_id
    GROUP BY GROUPING SETS(
            (d.player_name, d.team_abbreviation),
            (d.player_name, g.season),
            -- we need game_id, and team in this set because eventually
            -- we need to find a winner per game, right now we have winner data 
            -- for that game_id.
            -- since the records granularity is manny records per game,
            -- we included game_id to the grouping set.
            (d.game_id, d.team_abbreviation)
        )
)
-- in this query we are grouping with winner to count how many games won.
-- Team SAS won the most win.
SELECT winner AS team,
    count(1) AS win_count
FROM grouped_data
WHERE game_id IS NOT NULL
    AND team_abbreviation IS NOT NULL
    AND winner IS NOT NULL
GROUP BY winner
ORDER BY win_count DESC
LIMIT 1