select MAX_BY(player_name, pts) as player_name,
MAX_BY(team_abbreviation, pts) as player_name,
max(pts) as max_pts
from ykshon52797255.nba_grouping_sets
where team_abbreviation != '(overall)' and player_name != '(overall)'
