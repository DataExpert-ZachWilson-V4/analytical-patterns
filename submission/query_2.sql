-- This query calculates total points scored in NBA games, providing subtotals and overall totals.
with
    game_details_cte AS (
        select
            ngd.*,
            ng.season
        from
            -- Join game details with games metadata
            bootcamp.nba_game_details_dedup ngd -- using pre-deduped table that exist in bootcamp schema
            inner join bootcamp.nba_games ng on ngd.game_id = ng.game_id
    )
SELECT
    -- Use COALESCE to handle nulls, defaulting to 'Overall' for aggregate rows
    coalesce(player_name, 'Overall') as player,
    coalesce(team_abbreviation, 'Overall') as team,
    coalesce(cast(season as varchar), 'Overall') as season,
    
    -- Sum points, treating nulls as 0
    sum(
        case
            when pts is null then 0
            else pts
        end
    ) as total_points
from
    game_details_cte
group by
    -- Grouping sets to create subtotals for each player, team, and season
    GROUPING SETS (
        (player_name, team_abbreviation),
        (player_name, season),
        (team_abbreviation)
    )
order by
    -- Order results by player, team, and season
    player,
    team,
    season