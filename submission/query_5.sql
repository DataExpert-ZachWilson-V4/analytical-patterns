--Query that defines teams that won the most game
WITH max_wins AS (
    SELECT
        MAX(total_games_won) AS max_wins --gets maximum wins
    FROM
        amaliah21315.nba_game_details_grouped
    WHERE
        grouping_category = 'team_only'
        AND total_games_won IS NOT NULL --excludes unnecessary records where there are no points
)
SELECT
    team_abbreviation,
    total_games_won
FROM
    amaliah21315.nba_game_details_grouped
    JOIN max_wins ON total_games_won = max_wins
WHERE
    grouping_category = 'team_only' -- selects category by teams only
ORDER BY
    total_games_won DESC
LIMIT 1 