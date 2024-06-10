
-- Create or replace the table nba_game_details_groupingsets with the aggregated results
create or replace table sumanacheera.nba_game_details_groupingsets as 
select  
    -- Select player name or 'Overall' if it's null
    coalesce(gd.player_name, 'Overall') as player,
    -- Select team abbreviation or 'Overall' if it's null
    coalesce(gd.team_abbreviation, 'Overall') as team,
    -- Select season as varchar or 'Overall' if it's null
    coalesce(cast(g.season as varchar), 'Overall') as season,
    -- Determine the grouping type based on which dimensions are grouped
    case   
        when grouping(gd.player_name, gd.team_abbreviation) = 0 then 'player_team'
        when grouping(gd.player_name, g.season) = 0 then 'player_season'
        when grouping(gd.team_abbreviation) = 0 then 'team'
    end as grouping_type,
    -- Sum of points for the grouping
    sum(gd.pts) as total_points,
    -- Sum of wins for the grouping, counting if the team won the game
    sum(if(
        (gd.team_id = g.home_team_id and g.home_team_wins = 1) or
        (gd.team_id = g.visitor_team_id and g.home_team_wins = 0),
        1,
        0
    )) as wins
from bootcamp.nba_game_details_dedup as gd                  -- From the deduplicated game details table
join bootcamp.nba_games as g on gd.game_id = g.game_id      -- Join with games table on game_id
group by grouping sets(                                     -- Perform grouping sets aggregation
    (player_name, team_abbreviation),                       -- Group by player and team
    (player_name, season),                                  -- Group by player and season
    (team_abbreviation)                                     -- Group by team
)
