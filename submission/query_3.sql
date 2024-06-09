-- The goal is to identify the player who scored the most points while playing for a single team.
-- The process involves deduplicating game and game detail records, joining them, converting playing time to seconds, 
-- aggregating data to calculate total points per player per team, and then identifying the top scorer.

WITH
  -- Deduplicate games by selecting the latest record for each game_id
  games AS (
    SELECT
      game_id,
      season,
      home_team_id,
      visitor_team_id,
      home_team_wins,
      ROW_NUMBER() OVER (
        PARTITION BY game_id
      ) AS rank_dedup
    FROM
      bootcamp.nba_games
  ),
  games_dedup AS (
    SELECT
      *
    FROM
      games
    WHERE
      rank_dedup = 1
  ),
  -- Deduplicate game details by selecting the latest record for each game_id, team_id, and player_id
  game_details AS (
    SELECT
      team_id,
      game_id,
      team_abbreviation,
      player_name,
      player_id,
      min,
      fgm,
      fga,
      pts,
      ROW_NUMBER() OVER (
        PARTITION BY game_id, team_id, player_id
      ) AS rank_dedup
    FROM
      bootcamp.nba_game_details
  ),
  game_details_dedup AS (
    SELECT
      *
    FROM
      game_details
    WHERE
      rank_dedup = 1
  ),
  -- Join deduplicated game details with deduplicated games
  joined_games AS (
    SELECT
      a.*,
      season,
      home_team_id,
      visitor_team_id,
      home_team_wins
    FROM
      game_details_dedup a
    JOIN games_dedup b ON a.game_id = b.game_id
  ),
  -- Convert minutes played by players into total seconds
  converted_minutes AS (
    SELECT
      *,
      CAST(SPLIT_PART(min, ':', 1) AS DECIMAL) * 60 + CAST(SPLIT_PART(min, ':', 2) AS DECIMAL) AS total_seconds
    FROM
      joined_games
  ),
  -- Aggregate data by player name, team abbreviation, and season
  aggregate_data AS (
    SELECT
      COALESCE(player_name, '(overall)') AS player_name,
      COALESCE(CAST(season AS VARCHAR), '(overall)') AS season,
      COALESCE(team_abbreviation, '(overall)') AS team_abbreviation,
      MAX(game_id) AS game_id,
      MAX(team_id) AS team_id,
      MAX(player_id) AS player_id,
      SUM(total_seconds) AS total_minutes_in_seconds,
      SUM(fgm) AS total_field_goals_made,
      SUM(fga) AS total_field_goals_attempted,
      SUM(pts) AS total_points
    FROM
      converted_minutes
    GROUP BY
      GROUPING SETS (
        (player_name, team_abbreviation),
        (player_name, season),
        (team_abbreviation)
      )
  ),
  -- Calculate total points per player per team and rank them
  top_scorers AS (
    SELECT
      player_name,
      team_abbreviation,
      SUM(total_points) AS total_points,
      DENSE_RANK() OVER (ORDER BY SUM(total_points) DESC) AS rank_top
    FROM
      aggregate_data
    WHERE
      season = '(overall)'
      AND player_name != '(overall)'
      AND team_abbreviation != '(overall)'
    GROUP BY
      player_name,
      team_abbreviation
  )
-- Select the player who scored the most points for a single team
SELECT
  player_name
FROM
  top_scorers
WHERE
  rank_top = 1
