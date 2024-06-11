with home_team_count as(
SELECT home_team_id, sum(home_team_wins) over(partition by home_team_id order by game_id rows between 45 preceding and 45 following) as count_wins
FROM bootcamp.nba_games
),
wins_by_team as
select home_team_id, max(count_wins) as max_wins_by_team
from home_team_count
group by 1


select distinct team_abbreviation,max_wins_by_team
from wins_by_team w
inner join bootcamp.nba_game_details d
on w.home_team_id=d.team_id
where max_wins_by_team=(select max(max_wins_by_team) from wins_by_team)
