WITH
    team_win_counts as (
        SELECT
            team_id,
            team_abbreviation,
            SUM(
                CASE
                    WHEN n_wins > 0 THEN 1
                    WHEN n_wins = 0 THEN 0
                    ELSE 0
                END
            ) as n_team_wins
        FROM
            bgar.nba_grouping_sets
        WHERE
            level_id = 'team only'
        GROUP BY 1, 2
    )
SELECT
    MAX_BY(team_id, n_team_wins) as team_id,
    MAX_BY(team_abbreviation, n_team_wins) as team_abbreviation,
    MAX(n_team_wins) as max_team_wins
FROM
    team_win_counts
