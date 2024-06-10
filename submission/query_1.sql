--state change tracking for nba_players
with last_year AS(
    select * from vaishnaviaienampudi83291.nba_players_tracker
    where season=2001 
), -- collect previous years data
current_year AS(
    select player_name, 
    max(current_season) as active_season,
    max(is_active) as is_active
     from bootcamp.nba_players
    where current_season=2002
    group by player_name
), -- this years data
combined AS(
    select 
    coalesce(ly.player_name,cy.player_name) as player_name,
    ly.last_active_season as previous_active_year, --get the last active year
    ly.is_active as is_active_previous_year, -- is active last year
    ly.season_active_state as previous_active_state,  -- last active state
    cy.is_active,
    case when ly.seasons_active is null then Array[cy.active_season]
         when ly.seasons_active is not null and cy.active_season is not null then ly.seasons_active || Array[cy.active_season]
         when cy.active_season is null then ly.seasons_active end as seasons_active,
    case when ly.first_active_season is not null then ly.first_active_season
         when ly.first_active_season is null and cy.is_active then cy.active_season end as first_active_season,
    -- for first active season check if the last year's first_active_season is not null, if not then use last year's value.
    -- if not, check if player is active this year, if yes, the  use this years active season value     
    case when cy.is_active then cy.active_season else ly.last_active_season end as last_active_season,
    -- Similarly, for last_active_season we need to check if the player is active current year, if yes, then use this year's value else use last year's
    coalesce(ly.season+1, cy.active_season) as season
    from last_year ly 
    full outer join current_year cy 
    on ly.player_name = cy.player_name
)
select 
player_name,
first_active_season,
last_active_season,
seasons_active,
case  when first_active_season - last_active_season = 0 and is_active then 'New'
      when season - previous_active_year = 1 and NOT is_active then 'Retired'
      when season - previous_active_year = 1 and is_active then 'Continued Playing'
      when is_active and NOT is_active_previous_year then 'Returned from Retirement'
      else 'Stay Retired'
end as season_active_state
from combined 
where player_name is not null 