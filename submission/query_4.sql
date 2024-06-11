WITH
    nba_base AS (
        SELECT
            player_id,
            season,
            sum_pts AS total_points
        FROM
            phabrahao.nba_group_sets
        WHERE
            season <> '(overall)'
            AND player_id <> '(overall)'
            AND team_id = '(overall)'
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
    RANK AS (
        SELECT
            nba.*,
            player_name,
            DENSE_RANK() OVER (
                ORDER BY
                    total_points DESC
            ) AS RANK
        FROM
            nba_base nba
            LEFT JOIN player_names pn ON nba.player_id = pn.player_id
    )
SELECT
    *
FROM
    RANK
WHERE
    RANK = 1
