WITH team_wins AS (
    -- Selecting team name and total wins from the specified table
    SELECT
        team,
        total_win
    FROM
        raj.nba_games_grouping
    WHERE
        -- Filtering for rows representing a single team,
        -- and where wins are available
        Agg_Level = 'team'
        AND total_win IS NOT NULL
)
-- Selecting the top team based on total wins
SELECT
    team,
    total_win
FROM
    team_wins
ORDER BY
    total_win DESC      -- Sorting the rows in descending order based on the wins to bring the team with most wins to the top
LIMIT 1
