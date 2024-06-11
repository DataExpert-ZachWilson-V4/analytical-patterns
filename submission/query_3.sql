WITH player_team_agg AS
(
SELECT 
  aggregation_level,
  player,
  Team,
  Player_Total_Points,
  Dense_Rank() OVER(ORDER BY Player_Total_Points DESC) AS rnk -- Logic to avoid reading the table twice by first fetching the max points and using that as filter. Rather reading the data on a whole and applying the window function.
FROM Jaswanthv.nba_games_aggregate WHERE aggregation_level = 'Player__Team'
)
SELECT 
  player,
  Team,
  Player_Total_Points
FROM player_team_agg WHERE rnk = 1

-- LeBron James	CLE	28314

--Pushing dummy change for autograder