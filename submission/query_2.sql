--GROUPING SETS to perform aggregations of the nba_game_details data.
CREATE OR REPLACE TABLE vaishnaviaienampudi83291.nba_grouping_data_sets as 
with deduped_data as (
    select ngd.*,
    ngd.team_abbreviation as team_name,
    ng.game_date_est,
    ng.season,
    case when visitor_team_id = ngd.team_id and home_team_wins = 1 then 0
         when visitor_team_id = ngd.team_id and home_team_wins = 0 then 1
        end as did_win,
        --calculating whether team won or lost
    ROW_NUMBER() OVER (PARTITION BY ngd.game_id, ngd.team_id, ngd.player_id order by ng.game_date_est) as rn 
    -- using row_number to de-dup the data
    from bootcamp.nba_game_details ngd 
    join bootcamp.nba_games ng 
    on ngd.game_id = ng.game_id

)
select 
CASE WHEN GROUPING(player_name, team_name) = 0 then 'player_and_team'
     WHEN GROUPING(player_name, season) = 0 then 'player_and_season'
     WHEN GROUPING(team_name) = 0 then 'team'
end as agg_data, --creating aggreggate levels
coalesce(player_name, 'overall') as player_name,
coalesce(team_name, 'overall') as team,
coalesce(cast(season as varchar), 'overall') as season,
sum(pts) as points, 
sum(did_win) as wins
from deduped_data 
where rn = 1
GROUP BY GROUPING SETS(
    (player_name, team_name),
    (player_name, season),
    (team_name)
)