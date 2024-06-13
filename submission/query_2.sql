
/*
CREATE TABLE hdamerla.nba_grouping_sets (
  aggregation_level   VARCHAR,
    player       VARCHAR,
     team   VARCHAR,
     season              VARCHAR,
    total_points        DOUBLE,
    team_wins           BIGINT
 )
 WITH (
     format = 'PARQUET',
     format_version = 2
 )
*/

Insert into
   hdamerla.nba_grouping_sets WITH nba_game_details_dedup AS 
   (
      SELECT
         *,
         ROW_NUMBER() OVER (PARTITION BY player_id, game_id, team_id) AS rownum 
      FROM
         bootcamp.nba_game_details 
   )
,
   nba_game_details_snapshot AS 
   (
      SELECT
         * 
      FROM
         nba_game_details_dedup 
      WHERE
         rownum = 1 
   )
,
   nba_games_dedup AS 
   (
      SELECT
         *,
         ROW_NUMBER() OVER (PARTITION BY game_id) AS rownum 
      FROM
         bootcamp.nba_games 
   )
,
   nba_games_snapshot AS 
   (
      SELECT
         * 
      FROM
         nba_games_dedup 
      WHERE
         rownum = 1 
   )
,
   preaggregation AS 
   (
      SELECT
         COALESCE(CAST(ngs.season AS VARCHAR), 'Unknown_Season') AS Season,
         COALESCE(ngds.player_name, 'Player_UnIdentified') AS Player,
         COALESCE(ngds.team_abbreviation, 'N/A') AS Team,
         ngds.pts AS pts,
         ngds.team_id AS team_id,
         ngs.home_team_id AS home_team_id,
         ngs.visitor_team_id AS visitor_team_id,
         ngs.home_team_wins AS home_team_wins 
      FROM
         nba_game_details_snapshot ngds 
         FULL OUTER JOIN
            nba_games_snapshot ngs 
            ON ngds.game_id = ngs.game_id 
   )
   SELECT
      CASE
         WHEN
            GROUPING(Player, Team) = 0 
         THEN
            'Player__Team' 
         WHEN
            GROUPING(Player, Season) = 0 
         THEN
            'Player__Season' 
         WHEN
            GROUPING(Team) = 0 
         THEN
            'Team' 
      END
      AS aggregation_level, COALESCE(Season, '(Overall)') AS Season, COALESCE(Player, '(Overall)') AS Player, COALESCE(Team, '(Overall)') AS Team, SUM(pts) AS total_points, SUM(
      CASE
         WHEN
            team_id = home_team_id 
            AND home_team_wins = 1 
         Then
            1 
         WHEN
            team_id = visitor_team_id 
            AND home_team_wins = 0 
         Then
            1 
         Else
            0 
      END
) AS team_wins 
   FROM
      preaggregation 
   GROUP BY
      GROUPING SETS ( (Player, Team), 
      (
         Player, Season
      )
, 
      (
         Team
      )
)
