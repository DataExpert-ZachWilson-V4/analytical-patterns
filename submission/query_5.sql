select
    team_abbreviation,
    max(team_wins) as total_wins
from
    abhishekshetty.week5_q2
where
    agg_level = 'team_name'
group by 
    team_abbreviation
order by 
    total_wins desc
limit 1

-- answer = SAS	with 1182 wins
