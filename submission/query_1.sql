/*
Create table mymah592.player_state_tracking(
  Player_name VARCHAR,
  First_Active_Season integer,
  last_active_season integer,
  Seasons_active ARRAY(integer),
  Season_active_state VARCHAR,
  current_season integer


)
with
(Format ='PARQUET', partitioning = ARRAY['current_season'])

  */

Insert INTO

  mymah592.player_state_tracking
  
  With CTE_last_season as(
    SELECT * FROM mymah592.player_state_tracking
  WHERE current_season  = 2000
  
  ),

  /*
next CTE will get next increment data and set up for combined and logic
  */

CTE_current_season as (
  SELECT
    Player_name,
    max(is_active) as is_active,
    max(years_since_last_active) as years_since_last_active,
    max(current_season) as active_season
  FROM
    bootcamp.nba_players
  WHERE
    current_season = 2001
  GROUP by Player_name
),

/*
Combining both CTE's to handle new players and returning players. 
*/

Combined as(
  SELECT 
    COALESCE(cls.Player_name, ccs.Player_name) as Player_name,
    COALESCE(cls.First_Active_Season, ccs.active_season) as First_Active_Season,
    Case  
        When ccs.is_active = TRUE then ccs.active_season
        else cls.last_active_season
        end as last_active_season,
    cls.last_active_season as last_active_last_season,
    CASE
        when ccs.is_active = TRUE then ccs.active_season
        else NULL
        end as active_season,
    CASE
        WHEN cls.Seasons_active is NULL Then ARRAY[ccs.active_season]
        WHEN ccs.active_season is NULL or ccs.is_active = FALSE THEN cls.Seasons_active
        ELSE cls.Seasons_active || ARRAY[ccs.active_season]
        END as Seasons_active,
      2001 as Partition_season
    FROM
      CTE_last_season cls
      FULL OUTER JOIN CTE_current_season ccs ON cls.Player_name = ccs.Player_name
)
/*
- Write a query (`query_1`) that does state change tracking for `nba_players`. Create a state change-tracking field that takes on the following values:
  - A player entering the league should be `New`
  - A player leaving the league should be `Retired`
  - A player staying in the league should be `Continued Playing`
  - A player that comes out of retirement should be `Returned from Retirement`
  - A player that stays out of the league should be `Stayed Retired`
 */

 SELECT
  Player_name,
  First_Active_Season,
  last_active_season,
  Seasons_active,
  CASE
    WHEN active_season_diff_first = 0 THEN 'NEW'
    WHEN active_season_diff_last > 1 THEN 'Returned from Retirement'
    WHEN active_season_diff_last = 0 THEN 'Continued Playing'
    When active_season IS NULL and Partition_season_diff_last = 1 THEN 'Retired'
    ELSE 'Stayed Retired'
  END as Season_active_state,
  Partition_season
  FROM 
  (
    Select *,
    active_season - First_Active_Season as active_season_diff_first,
    active_season - last_active_last_season as active_season_diff_last,
    partitions_season - last_active_season as Partition_season_diff_last
    FROM combined
  )
  
