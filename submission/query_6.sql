-- Combine home and away games
WITH combined_games AS (
    SELECT game_id, home_team_id AS team_id, home_team_wins
    FROM bootcamp.nba_games
    UNION ALL
    SELECT game_id, visitor_team_id, 1 - home_team_wins AS home_team_wins
    FROM bootcamp.nba_games
),
--Finding rolling sum of wins by team over 90 game stretch
home_team_count as(
SELECT home_team_id, sum(home_team_wins) over(partition by home_team_id order by game_id rows between 89 preceding and current row) as count_wins
FROM combined_games
),
--Find max count of wins for each team
wins_by_team as(
select home_team_id, max(count_wins) as max_wins_by_team
from home_team_count
group by 1
)
--Display team and total wins for team with maximum wins
select distinct team_abbreviation,max_wins_by_team
from wins_by_team w
inner join bootcamp.nba_game_details d
on w.home_team_id=d.team_id
where max_wins_by_team=(select max(max_wins_by_team) from wins_by_team)
