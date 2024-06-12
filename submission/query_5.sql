WITH team_wins AS(
    SELECT 
        team_abbreviation,
        sum(game_wins) AS game_wins
    FROM supreethkabbin.nba_game_grouping
    WHERE aggregation_level = 'player_and_team'
    group by 
        team_abbreviation
)
SELECT team_abbreviation
FROM team_wins
WHERE game_wins = (
            SELECT 
                max(game_wins) 
            FROM team_wins
)
