WITH game_details_dedup AS ( --needed to dedup the nba_game_details, which grew even more since the week 2 homework
  SELECT
    *
    ,ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) as rownum
  FROM bootcamp.nba_game_details
),
combined AS (
  SELECT
    gd.player_name
    , gd.team_id
    , gd.team_abbreviation
    , gd.pts --it appears that 0 points means a player played in a game without scoring, whereas a null indicates they didn't play
    , gd.min --added this field to determine for sure if a player played in a game even without any points
    , g.home_team_id
    , g.visitor_team_id
    , g.season
    , g.game_id
    , g.home_team_wins
  FROM game_details_dedup gd
  JOIN bootcamp.nba_games g on gd.game_id = g.game_id
  WHERE gd.rownum = 1 --this dedups the results from the first CTE
),
aggregated AS (
  SELECT
    COALESCE(player_name, '(Overall)') as player
    , COALESCE(team_abbreviation, '(Overall)') as team
    , COALESCE(CAST(season as VARCHAR), '(Overall)') as season
    , SUM(pts) as sum_of_pts
    , SUM(CASE WHEN min IS NULL THEN 0 WHEN min = '0' THEN 0
    ELSE 1 END) as games_played --this aggregation may produce more games played than recorded in the nba_player_seasons.gp field; the more detailed grain is used here since I cannot troubleshoot the pre-aggregated amount in nba_player_seasons
    , SUM(CASE WHEN team_id = home_team_id AND home_team_wins = 1 THEN 1
    WHEN team_id = visitor_team_id AND home_team_wins = 0 THEN 1 ELSE 0 END) as wins --wins are semi-additive and should be removed for the team_abbreviation grouping set; this can be done by adding another CTE then a CASE statement to return nulls for the overall team_abbreviation grouping.
  FROM combined
  GROUP BY
    GROUPING SETS (
      (player_name, season),
      (player_name, team_abbreviation),
      (team_abbreviation)
    )
)

SELECT
  season
  , MAX(sum_of_pts) as max_pts
  , MAX_BY(player, sum_of_pts) as player_with_max
FROM aggregated
WHERE season <> '(Overall)'
GROUP BY season
ORDER BY 1