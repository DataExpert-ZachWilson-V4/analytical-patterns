WITH
    ranked AS (
        SELECT
            player_name,
            season,
            total_player_points,
            DENSE_RANK() OVER(partition by season ORDER BY total_player_points DESC) AS rnk -- get the player with top rank
        FROM
            lsleena.game_agg_details
        WHERE
            player_name IS NOT NULL
)
SELECT
    player_name,
    season,
    total_player_points
FROM
    ranked
WHERE
    rnk = 1
