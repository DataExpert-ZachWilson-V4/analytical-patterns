INSERT INTO sanchit.nba_players_state_tracking
WITH
yesterday AS (
    SELECT
        player_name,
        first_active_season,
        last_active_season,
        seasons_active,
        yearly_active_state,
        season
    FROM
        sanchit.nba_players_state_tracking
    WHERE
        season = 2001
),

today AS (
    SELECT
        player_name,
        max(is_active) AS is_active,
        max(current_season) AS seasons_active
    FROM
        bootcamp.nba_players
    WHERE
        current_season = 2002
    GROUP BY
        player_name
),

combined AS (
    SELECT
        t.is_active,
        y.last_active_season AS y_last_active_season,
        coalesce(y.player_name, t.player_name) AS player_name,
        coalesce(
            y.first_active_season,
            (CASE WHEN t.is_active THEN t.seasons_active END)
        ) AS first_active_season,
        coalesce(
            (CASE WHEN t.is_active THEN t.seasons_active END),
            y.last_active_season
        ) AS last_active_season,
        CASE
            WHEN
                y.seasons_active IS null THEN array[t.seasons_active]
            WHEN t.seasons_active IS null THEN y.seasons_active
            WHEN
                t.seasons_active IS NOT null AND t.is_active
                THEN array[t.seasons_active] || y.seasons_active
            ELSE y.seasons_active
        END AS seasons_active,
        coalesce(y.season + 1, t.seasons_active) AS season
    FROM
        yesterday AS y
    FULL OUTER JOIN today AS t ON y.player_name = t.player_name
)

SELECT
    player_name,
    first_active_season,
    last_active_season,
    seasons_active,
    CASE
        WHEN
            is_active AND first_active_season - last_active_season = 0
            THEN 'new'
        WHEN
            is_active AND season - y_last_active_season = 1
            THEN 'continued playing'
        WHEN
            is_active AND season - y_last_active_season > 1
            THEN 'returned from retirement'
        WHEN
            NOT is_active
            AND season - y_last_active_season = 1 THEN 'retired'
        ELSE 'stayed retired'
    END AS yearly_active_state,
    season
FROM
    combined
