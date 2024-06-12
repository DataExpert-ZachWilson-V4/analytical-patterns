create or replace table sanchit.game_details_dashboard as
with
combined as (
    select
        player_name,
        season,
        coalesce(team_city, 'n/a') as team,
        sum(a.pts) as total_player_points,
        sum(
            case
                when
                    (a.team_id = b.home_team_id and home_team_wins = 1)
                    or (a.team_id = b.visitor_team_id and home_team_wins = 0) then 1
                else 0
            end
        ) as total_games_won
    from
        bootcamp.nba_game_details_dedup as a
    inner join
        bootcamp.nba_games as b
        on
            a.game_id = b.game_id
    group by
        grouping sets (
            (player_name, team_city),
            (player_name, season),
            (team_city)
        )
)

select *
from
    combined
