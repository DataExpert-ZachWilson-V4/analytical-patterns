WITH
    nba_base AS (
        SELECT
            team_id,
            team_wins AS total_wins
        FROM
            phabrahao.nba_group_sets
        WHERE
            team_id <> '(overall)'
            AND player_id = '(overall)'
            AND season = '(overall)'
    ),
    team_abb AS (
        SELECT
            cast(team_id AS VARCHAR) team_id,
            team_abbreviation
        FROM
            bootcamp.nba_game_details_dedup
        GROUP BY
            team_id,
            team_abbreviation
    ),
    RANK AS (
        SELECT
            nba.*,
            team_abbreviation,
            DENSE_RANK() OVER (
                ORDER BY
                    total_wins DESC
            ) AS RANK
        FROM
            nba_base nba
            LEFT JOIN team_abb ta ON nba.team_id = ta.team_id
    )
SELECT
    *
FROM
    RANK
WHERE
    RANK = 1
