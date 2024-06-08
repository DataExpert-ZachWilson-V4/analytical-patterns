-- Find player that scored the most points in one season
select
    max_by(player_id, total_points) as player_id,
    max_by(player_name, total_points) as player_name,
    max_by(season, total_points) as season,
    max(total_points) as max_total_points
from
    sarneski44638.nba_grouping_sets
where
    level_id = 'player_and_season_level'
