With nba_game_details_dedup As
(
Select
  game_id,
  team_id,
  team_abbreviation,
  player_id,
  player_name,
  pts,
  ROW_NUMBER() Over (Partition by player_id,game_id, team_id order by player_id, game_id, team_id) As rnk
from bootcamp.nba_game_details
order by game_id
)
, nba_details As
(
Select 
  game_id,
  team_id,
  team_abbreviation,
  player_id,
  player_name,
  pts 
from nba_game_details_dedup where rnk = 1
)
, nba_games_dedup As
(
Select 
game_id,
season,
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
  season,
  home_team_id,
  visitor_team_id,
  home_team_wins
from nba_games_dedup where rnk = 1
)
, Preagg As
(
	Select
    	COALESCE(CAST(ng.season As VARCHAR),'Unknown_Season') As Season,
    	COALESCE(nd.player_name,'Player_UnIdentified') As Player,
    	COALESCE(nd.team_abbreviation,'N/A') As Team,
		nd.pts As pts,
		nd.team_id As team_id,
		ng.home_team_id As home_team_id,
		ng.visitor_team_id  As visitor_team_id,
		ng.home_team_wins As home_team_wins
	From nba_details nd Join nba_games ng
	on nd.game_id = ng.game_id
)
, Grouped_Sets As (
Select
  COALESCE(Season,'(Overall)') As Season,
  COALESCE(Player,'(Overall)') As Player,
  COALESCE(Team,'(Overall)') As Team,
  SUM(pts) As Player_Total_Points,
  SUM(CASE
        WHEN team_id = home_team_id and home_team_wins = 1 Then 1
        WHEN team_id = visitor_team_id and home_team_wins = 0 Then 1
        Else 0 
      END) As Total_Wins        
From Preagg
Group by
GROUPING SETS (
(Player,Team),
(Player,Season),
(Team)
)
)
,High_Score As
(
Select 
  player,
  Team,
  Player_Total_Points,
  Dense_Rank() Over(Order by Player_Total_Points Desc) as rnk
From Grouped_Sets where Player <> '(Overall)' and Team <> '(Overall)'
)
Select * from High_Score where rnk = 1

-- LeBron James	CLE	28314

--Pushing dummy change for autograder