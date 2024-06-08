-- Q3 Find player that scored the most points playing for a single team
select
    max_by(player_id, total_points) as player_id,
    max_by(player_name, total_points) as player_name,
    max_by(team_id, total_points) as team_id,
    max_by(team_abbreviation, total_points) as team_abbreviation,
    max(total_points) as max_total_points
from
    sarneski44638.nba_grouping_sets
where
    level_id = 'player_and_team_level'