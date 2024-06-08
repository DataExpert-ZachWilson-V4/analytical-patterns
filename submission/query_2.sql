insert into
    sarneski44638.nba_grouping_sets
with
    deduped_games as (
        select
            game_id,
            home_team_id,
            visitor_team_id,
            max(home_team_wins) as home_team_wins,
            max(season) as season
        from
            bootcamp.nba_games
        group by
            game_id,
            home_team_id,
            visitor_team_id
    )
select
    case
        when grouping (player_id) = 0
        and grouping (team_id) = 0 then 'player_and_team_level'
        when grouping (player_id) = 0
        and grouping (season) = 0 then 'player_and_season_level'
        when grouping (team_id) = 0
        and grouping (d.game_id) = 0 then 'game_team_level'
    end as level_id,
    player_id,
    player_name,
    team_id,
    team_abbreviation,
    d.game_id,
    season,
    sum(pts) AS total_points,
    sum(
        case
            when team_id = home_team_id
            and home_team_wins = 1 then 1
            when team_id = visitor_team_id
            and home_team_wins = 0 then 1
            else 0
        end
    ) as n_wins -- be careful at game_team_level this is aggregating for all players; if > 0 then is win (as team) otherwise not win
from
    bootcamp.nba_game_details_dedup as d
    join deduped_games g on d.game_id = g.game_id
group by
    grouping sets (
        (
            player_id,
            player_name,
            team_id,
            team_abbreviation
        ),
        (player_id, player_name, season),
        (d.game_id, team_id, team_abbreviation)
    )