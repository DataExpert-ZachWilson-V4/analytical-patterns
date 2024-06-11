WITH player_season_agg AS
(
SELECT 
  player,
  Season,
  Player_Total_Points,
  Dense_Rank() OVER(ORDER BY Player_Total_Points DESC) AS rnk -- Logic to avoid reading the table twice by first fetching the max points and using that as filter. Rather reading the data on a whole and applying the window function.
FROM Jaswanthv.nba_games_aggregate WHERE aggregation_level = 'Player__Season'
)
SELECT 
  player,
  season,
  Player_Total_Points
FROM player_season_agg WHERE rnk = 1

-- Kevin Durant	2013	3265

--Pushing dummy change for autograder