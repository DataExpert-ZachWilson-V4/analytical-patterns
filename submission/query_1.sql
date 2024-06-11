INSERT INTO adbeyer.nba_state_change
WITH last_season
     AS (SELECT *
         FROM   adbeyer.nba_state_change
         WHERE  current_season = 1999),
     this_season
     AS (SELECT *,
                Row_number()
                  over(
                    PARTITION BY player_name, current_season ) AS row_number
         FROM   bootcamp.nba_players
         WHERE  current_season = 2000
                AND is_active = TRUE),
     this_season_deduped
     AS (SELECT *
         FROM   this_season
         WHERE  row_number = 1),
     combined
     AS (SELECT Coalesce(ls.player_name, ts.player_name)            AS
                player_name,
                Coalesce(ls.first_active_season, ts.current_season) AS
                   first_active_season,
                Coalesce(ts.current_season, ls.last_active_season)  AS
                   last_active_season,
                ts.current_season                                   AS
                current_season
                ,
                ls.active_state                                     AS
                last_active_state

         FROM   last_season ls
                full outer join this_season_deduped ts
                             ON ls.player_name = ts.player_name)
SELECT player_name,
       first_active_season,
       last_active_season,
       CASE
        WHEN current_season - first_active_season = 0 THEN 'New'
        WHEN years_since_last_active = 1 THEN 'Retired'
        WHEN active_status_today = true AND last_active_season - last_active_season_yesterday = 1 THEN 'Continued Playing'
        WHEN active_status_today = true AND last_active_season - last_active_season_yesterday > 1 THEN 'Returned from Retirement'
        WHEN years_since_last_active > 1 THEN 'Stayed Retired'
    END as season_active_state,
    current_season
FROM   combined 
