WITH combined as (
  SELECT
    a.player_name
    , a.team_id
    , a.team_abbreviation
    , a.pts -- 0 points means a player played in game without scoring, a null indicates they didn't play
    , a.min --to determine for sure if a player played a game even without any points
    , b.home_team_id
    , b.visitor_team_id
    , b.season
    , b.game_id
    , b.home_team_wins
  FROM saismail.nba_game_details_deduped a
  JOIN bootcamp.nba_games b on a.game_id = b.game_id
)
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