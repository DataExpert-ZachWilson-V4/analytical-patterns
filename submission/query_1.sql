-- CREATE TABLE farahakoum199912722.nba_players_state_tracking (
--   player_name VARCHAR,
--   first_active_season INTEGER,
--   last_active_season INTEGER,
--   season_active_state VARCHAR,
--   current_season INTEGER
-- ) WITH (FORMAT = 'PARQUET', partitioning = ARRAY['season'])

WITH yesterday AS (SELECT *
                   FROM farahakoum199912722.nba_players_state_tracking
                   WHERE current_season = 1996
    ),
    today AS (SELECT
                    player_name,
                    current_season,
                    MIN(s.season) AS first_active_season,
                    MAX(s.season) AS last_active_season
              FROM bootcamp.nba_players,
                UNNEST(seasons) s
              WHERE current_season = 1997
    GROUP BY 1, 2
    ),
    combined AS (SELECT
                    COALESCE (y.player_name, t.player_name) AS player_name,
                    CASE
                        WHEN y.player_name IS NULL THEN t.first_active_season
                        ELSE y.first_active_season
                    END AS first_active_season,
                    CASE
                        WHEN t.current_season - t.last_active_season != 0 THEN y.last_active_season
                        ELSE t.current_season
                    END AS last_active_season,
                    y.last_active_season AS season_yesterday,
                    t.current_season
                 FROM yesterday y
                    FULL OUTER JOIN today t
                        ON y.player_name = t.player_name
    )
SELECT player_name,
       first_active_season,
       last_active_season,
       CASE
           WHEN current_season - first_active_season = 0 THEN 'New'
           WHEN last_active_season - season_yesterday = 0 THEN 'Continued Playing'
           WHEN current_season - last_active_season = 1 THEN 'Retired'
           WHEN current_season - season_yesterday > 1 AND current_season = last_active_season
                THEN 'Returned from Retirement'
           ELSE 'Stayed Retired'
       END AS season_active_state
FROM combined