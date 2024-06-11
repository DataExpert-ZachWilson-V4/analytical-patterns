CREATE TABLE phabrahao.nba_group_sets AS
WITH
    base AS (
        SELECT
            ngd.*,
            CASE
                WHEN ng_h.home_team_wins = 1 THEN 1.0
                ELSE 0.0
            END AS home_team_wins,
            CASE
                WHEN ng_v.home_team_wins = 0 THEN 1.0
                ELSE 0.0
            END AS visitor_team_wins,
            COALESCE(ng_h.season, ng_v.season) AS season,
            COUNT() OVER (
                PARTITION BY
                    ngd.game_id,
                    team_id
            ) AS count_players
        FROM
            bootcamp.nba_game_details_dedup ngd
            LEFT JOIN bootcamp.nba_games ng_h ON ng_h.game_id = ngd.game_id
            AND ng_h.home_team_id = ngd.team_id
            LEFT JOIN bootcamp.nba_games ng_v ON ng_v.game_id = ngd.game_id
            AND ng_v.visitor_team_id = ngd.team_id
    )
SELECT
    COALESCE(cast(player_id AS VARCHAR), '(overall)') AS player_id,
    COALESCE(cast(team_id AS VARCHAR), '(overall)') AS team_id,
    COALESCE(cast(season AS VARCHAR), '(overall)') AS season,
    avg(fga) AS avg_fga,
    avg(fg_pct) AS avg_fg_pct,
    sum(pts) AS sum_pts,
    sum((home_team_wins + visitor_team_wins) /count_players) AS team_wins
FROM
    base
GROUP BY
    GROUPING SETS (
        (player_id, team_id),
        (player_id, season),
        (team_id)
    )