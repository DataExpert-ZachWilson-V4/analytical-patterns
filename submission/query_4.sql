select MAX_BY(player_name, pts) as player_name,
MAX_BY(season, pts) as season,
max(pts) as max_pts
from ykshon52797255.nba_grouping_sets
where season != 9999 and player_name != '(overall)'
