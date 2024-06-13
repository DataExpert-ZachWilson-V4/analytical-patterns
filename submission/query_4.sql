select
    player_name,
    season,
    max(total_points) as points_max
from
    abhishekshetty.week5_q2
where
    agg_level = 'player_season'
group by 
    player_name,
    season
order by 
    points_max desc
limit 1

-- answer = Kevin Durant  in 2013 with 3265 points
