-- This query calculates total points scored in NBA games, providing subtotals and overall totals.
select
    -- Use COALESCE to handle nulls, defaulting to 'Overall' for aggregate rows
    coalesce(ngd.player_name, 'Overall') as player,
    coalesce(ngd.team_abbreviation, 'Overall') as team,
    coalesce(cast(ng.season as varchar), 'Overall') as season,
    -- Sum points, treating nulls as 0
    sum(
        case
            when ngd.pts is null then 0
            else ngd.pts
        end
    ) as total_points
from
    -- Join game details with games metadata
    bootcamp.nba_game_details_dedup ngd -- using pre-deduped table that exist in bootcamp schema
    inner join bootcamp.nba_games ng on ngd.game_id = ng.game_id
group by
    -- Grouping sets to create subtotals for each player, team, and season
    GROUPING SETS (
        (ngd.player_name, ngd.team_abbreviation),
        (ngd.player_name, ng.season),
        (ngd.team_abbreviation)
    )
order by
    -- Order results by player, team, and season
    player,
    team,
    season