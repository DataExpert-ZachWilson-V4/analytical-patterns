WITH
    nba_base AS (
        SELECT
            player_id,
            team_id,
            sum_pts AS total_points
        FROM
            phabrahao.nba_group_sets
        WHERE
            team_id <> '(overall)'
            AND player_id <> '(overall)'
            AND season = '(overall)'
    ),
    player_names AS (
        SELECT
            cast(player_id AS VARCHAR) player_id,
            player_name
        FROM
            bootcamp.nba_game_details_dedup
        GROUP BY
            player_id,
            player_name
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
            player_name,
            team_abbreviation,
            DENSE_RANK() OVER (
                ORDER BY
                    total_points DESC
            ) AS RANK
        FROM
            nba_base nba
            LEFT JOIN player_names pn ON nba.player_id = pn.player_id
            LEFT JOIN team_abb ta ON nba.team_id = ta.team_id
    )
SELECT
    *
FROM
    RANK
WHERE
    RANK = 1
