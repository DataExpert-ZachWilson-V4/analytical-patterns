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
),
aggregated AS(
SELECT
  COALESCE(player_name, '(Overall)') as player
  , COALESCE(team_abbreviation, '(Overall)') as team
  , COALESCE(CAST(season as VARCHAR), '(Overall)') as season
  , SUM(pts) as sum_of_pts
  , SUM(CASE WHEN min IS NULL THEN 0 WHEN min = '0' THEN 0 ELSE 1 END) as games_played 
  , SUM(CASE WHEN team_id = home_team_id AND home_team_wins = 1 THEN 1
             WHEN team_id = visitor_team_id AND home_team_wins = 0 THEN 1 ELSE 0 END) as wins 
FROM combined
GROUP BY
  GROUPING SETS (
    (player_name, season),
    (player_name, team_abbreviation),
    (team_abbreviation)
  )
)

SELECT 
    team
    , MAX(sum_of_pts) as max_pts
    , MAX_BY(player, sum_of_pts) as player_with_max_pts
    FROM aggregated
    WHERE season <> '(Overall)'
    GROUP BY season
    ORDER BY max_pts DESC
    LIMIT 1