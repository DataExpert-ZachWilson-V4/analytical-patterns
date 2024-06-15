WITH
  ranking AS (
    SELECT
      *,
      -- create row number to dedupe by game_id, team_id and player_id
      ROW_NUMBER() OVER (
        PARTITION BY
          game_id,
          team_id,
          player_id
      ) row_num
    FROM
      bootcamp.nba_game_details
  )
  , nba_games_deduped AS (
    -- select single row for the selected columns to eliminate rows for each player
    SELECT game_id
        , home_team_id
        , season
        , home_team_wins
    FROM bootcamp.nba_games
    GROUP BY game_id
        , home_team_id
        , season
        , home_team_wins
  )
, winning_team AS (
  SELECT ran.team_abbreviation
       , ran.game_id
       , ran.team_id
       , ran.player_name
       , nba.season
       -- if team won is the home team then no_of_wins is 1
       -- if team won is away_team then no_of_wins is 1
       -- else if either team loses then no_of_wins is 0
       , CASE WHEN ran.team_id = nba.home_team_id and nba.home_team_wins = 1 THEN 1
       WHEN ran.team_id != nba.home_team_id and nba.home_team_wins = 0 THEN 1
       ELSE 0 END AS wins
  FROM ranking ran
  INNER JOIN nba_games_deduped nba ON ran.game_id = nba.game_id
WHERE ran.row_num = 1
)
, grouped_sets AS (
SELECT COALESCE(player_name, 'total') AS player_name,
  COALESCE(team_abbreviation, 'total') AS team,
  COALESCE(CAST(season AS VARCHAR), 'total') AS season,
  SUM(wins) AS team_wins
FROM
  winning_team
GROUP BY
  GROUPING SETS (
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation),
    ()
  )
)
-- "Which team has won the most games"
SELECT team
FROM (
SELECT team
     , team_wins
     , ROW_NUMBER() OVER(ORDER BY team_wins DESC) AS row_cnt
FROM grouped_sets
-- filter for the grouping set where records are grouped by team
-- player and season is not considered in the group and hence is rolled up at overall level
WHERE season = 'total'
AND team != 'total'
AND player_name = 'total'
)ranked
WHERE ranked.row_cnt = 1