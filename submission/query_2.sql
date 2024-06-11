CREATE OR REPLACE TABLE Jaswanthv.nba_games_aggregate AS
With nba_game_details_dedup AS
(
SELECT
  game_id,
  team_id,
  team_abbreviation,
  player_id,
  player_name,
  pts,
  ROW_NUMBER() Over (Partition by player_id,game_id, team_id ORDER BY player_id, game_id, team_id) AS rnk
FROM bootcamp.nba_game_details
)
, nba_details AS
(
SELECT 
  game_id,
  team_id,
  team_abbreviation,
  player_id,
  player_name,
  pts 
FROM nba_game_details_dedup WHERE rnk = 1
)
, nba_games_dedup AS
(
SELECT 
game_id,
season,
home_team_id,
visitor_team_id,
home_team_wins,
ROW_NUMBER() OVER(PARTITION BY game_id ORDER BY game_id) AS rnk  -- Deduping the data
FROM bootcamp.nba_games
)
, nba_games AS
(
SELECT 
  game_id,
  season,
  home_team_id,
  visitor_team_id,
  home_team_wins
FROM nba_games_dedup WHERE rnk = 1
)
, Preagg AS
(
	SELECT
    	COALESCE(CAST(ng.season AS VARCHAR),'Unknown_Season') AS Season, -- Handling Nulls here so that the Grouping sets Null Handling doesn't overwrite source nulls with the Grouping set Null handling values.
    	COALESCE(nd.player_name,'Player_UnIdentified') AS Player,
    	COALESCE(nd.team_abbreviation,'N/A') AS Team,
		nd.pts AS pts,
		nd.team_id AS team_id,
		ng.home_team_id AS home_team_id,
		ng.visitor_team_id  AS visitor_team_id,
		ng.home_team_wins AS home_team_wins
	FROM nba_details nd JOIN nba_games ng
	ON nd.game_id = ng.game_id
)

SELECT
    CASE 
        WHEN GROUPING(Player, Team) = 0 THEN 'Player__Team'
        WHEN GROUPING(Player, Season) = 0 THEN 'Player__Season'
        WHEN GROUPING(Team) = 0 THEN 'Team'
    END AS aggregation_level,
  	COALESCE(Season,'(Overall)') AS Season,
  	COALESCE(Player,'(Overall)') AS Player,
  	COALESCE(Team,'(Overall)') AS Team,
  	SUM(pts) AS Player_Total_Points,
  	SUM(CASE
        	WHEN team_id = home_team_id AND home_team_wins = 1 Then 1
        	WHEN team_id = visitor_team_id AND home_team_wins = 0 Then 1
        Else 0 
      	END) AS Total_Wins        
FROM Preagg
GROUP BY
GROUPING SETS (
(Player,Team),
(Player,Season),
(Team)
)


