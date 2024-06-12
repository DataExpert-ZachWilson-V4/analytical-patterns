select
    coalesce(ngd.player_name, 'Overall') as player,
    coalesce(ngd.team_abbreviation, 'Overall') as team,
    coalesce(cast(ng.season as varchar), 'Overall') as season,
    sum(
        case
            when ngd.pts is null then 0
            else ngd.pts
        end
    ) as total_points
from
    bootcamp.nba_game_details_dedup ngd
    inner join bootcamp.nba_games ng on ngd.game_id = ng.game_id
group by
    GROUPING SETS (
        (ngd.player_name, ngd.team_abbreviation),
        (ngd.player_name, ng.season),
        (ngd.team_abbreviation)
    )
order by
    player,
    team,
    season