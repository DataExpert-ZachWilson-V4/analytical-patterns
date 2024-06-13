/*
Write a query (query_1) that does state change tracking for nba_players. 
Create a state change-tracking field that takes on the following values:

- A player entering the league should be New
- A player leaving the league should be Retired
- A player staying in the league should be Continued Playing
- A player that comes out of retirement should be Returned from Retirement
- A player that stays out of the league should be Stayed Retired
*/

SELECT
    player_name,
    height,
    college,
    country,
    draft_year,
    draft_round,
    draft_number,
    seasons,
    is_active,
    years_since_last_active,
    current_season,
    CASE
        -- A player entering the league should be New
        WHEN is_active AND CARDINALITY(seasons) = 1 THEN 'New'
        -- A player leaving the league should be Retired
        WHEN NOT is_active AND years_since_last_active = 1 THEN 'Retired'
        -- A player staying in the league should be Continued Playing
        WHEN is_active AND years_since_last_active = 0 THEN 'Continued Playing'
        -- A player that comes out of retirement should be Returned from Retirement
        WHEN is_active AND years_since_last_active > 1 THEN 'Returned from Retirement'
        -- A player that stays out of the league should be Stayed Retired
        WHEN NOT is_active AND years_since_last_active > 1 THEN 'Stayed Retired'
    END AS season_state
FROM bootcamp.nba_players