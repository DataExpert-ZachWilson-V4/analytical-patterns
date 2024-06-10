select 
MAX_BY(team_abbreviation, team_wins) as team,
max(team_wins) as max_team_wins
from ykshon52797255.nba_grouping_sets
where team_abbreviation != '(overall)'
