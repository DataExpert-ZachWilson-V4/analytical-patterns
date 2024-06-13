insert into abhishekshetty.week5_q2
with nba_game_details as
(
select *, ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) AS row_num 
from bootcamp.nba_game_details
),
nba_game_details_dedup as (
    select *,  ROW_NUMBER() OVER (PARTITION BY team_id, game_id ORDER BY player_name) AS player_order --adding this line because we want to count wins of only 1 player
  -- adding this line helps because we can filter 1 player from each team
    from nba_game_details
    where row_num = 1
), -- removing deuplicates in the dedup tables
nba_games as
(
select game_id,
       season,
       home_team_id,
       visitor_team_id,
       home_team_wins,
       ROW_NUMBER() OVER (PARTITION BY game_id) as row_num
from bootcamp.nba_games
),
nba_games_dedup as 
(
select game_id,
       season,
       home_team_id,
       visitor_team_id,
       home_team_wins
from nba_games
where row_num = 1
)
select case when GROUPING(gdd.player_name, gdd.team_abbreviation) = 0 then 'player_team'  
            when GROUPING(gdd.player_name, gd.season) = 0 then 'player_season'
            when GROUPING(gdd.team_abbreviation) = 0 then 'team_name'
       end as agg_level, -- created aggreation levels using the grouping function
       coalesce(gdd.player_name, '(overall)') as player_name, --null handling
       coalesce(gdd.team_abbreviation, '(overall)') as team_abbreviation, --null handling
       coalesce(cast(gd.season as varchar), '(overall)') as season, --null handling
       sum(gdd.pts) AS total_points, --agrregation
       sum(case when gdd.player_order =1 
           then 
          (case when gdd.team_id = gd.home_team_id then gd.home_team_wins else (1-gd.home_team_wins) end)
           end ) AS team_wins -- calculating wins for the team
from
nba_game_details_dedup AS gdd
JOIN nba_games_dedup AS gd ON gdd.game_id = gd.game_id
group by GROUPING SETS(
            (gdd.player_name, gdd.team_abbreviation), -- group by player and team
            (gdd.player_name, gd.season), -- group by player and season
            (gdd.team_abbreviation) -- group by team
            )

