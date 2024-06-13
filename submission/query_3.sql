select
    player_name,
    team_abbreviation,
    max(total_points) as points_max
from
    abhishekshetty.week5_q2
where
    agg_level = 'player_team'
group by 
    player_name,
    team_abbreviation
order by 
    points_max desc
limit 1

-- answer = LeBron James	from CLE	with 28314 points
