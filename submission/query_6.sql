With nba_game_details_dedup As
(
Select
  game_id,
  team_id,
  team_abbreviation,
  ROW_NUMBER() Over (Partition by game_id, team_id order by game_id, team_id) As rnk
from bootcamp.nba_game_details
order by game_id
)
, nba_details As
(
Select 
  game_id,
  team_id,
  team_abbreviation
from nba_game_details_dedup where rnk = 1
)
, nba_games_dedup As
(
Select 
  game_id,
  game_date_est,
  home_team_id,
  visitor_team_id,
  home_team_wins,
  ROW_NUMBER() OVER(PARTITION BY game_id order by game_id) As rnk
from bootcamp.nba_games
order by game_id
)
, nba_games As
(
Select 
  game_id,
  game_date_est,
  home_team_id,
  visitor_team_id,
  home_team_wins
from nba_games_dedup where rnk = 1
)
, Preagg As
(
	Select
    	nd.game_id,
    	nd.team_abbreviation,
    	ng.game_date_est,
    	CASE
    	  WHEN (nd.team_id = ng.home_team_id) And ng.home_team_wins = 1 Then 1
    	  WHEN (nd.team_id = ng.visitor_team_id) And ng.home_team_wins = 0 Then 1
    	  Else 0 End As games_won
	From nba_details nd Join nba_games ng
	on nd.game_id = ng.game_id
)
, WinsCalculated As
(
Select 
  team_abbreviation As team,
  game_date_est,
  SUM(games_won) Over (Partition by team_abbreviation order by game_date_est ROWS BETWEEN 89 PRECEDING AND CURRENT ROW) As total_wins_90days
from Preagg
)
Select 
  team,
  Max(total_wins_90days) As max_90day_wins
from WinsCalculated
group by team 
Order by max_90day_wins Desc

--Pushing dummy change for autograder