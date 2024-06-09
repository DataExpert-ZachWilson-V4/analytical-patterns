-- The query aims to find the team that has won the most games.
-- 1. Deduplicate the games and game details tables to ensure we have the latest records.
-- 2. Join the deduplicated game details with deduplicated games.
-- 3. Convert the minutes played by players into total seconds.
-- 4. Aggregate data by player name, team abbreviation, and season.
-- 5. Calculate total wins for each team.
-- 6. Identify the team with the most wins.

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
        ORDER BY game_id DESC
      ) AS rank_dedup
    FROM
      bootcamp.nba_games
  ),
  -- Filter for the latest record per game
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
        ORDER BY game_id DESC
      ) AS rank_dedup
    FROM
      bootcamp.nba_game_details
  ),
  -- Filter for the latest record per game, team, and player
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
      SUM(pts) AS total_points,
      SUM(CASE
        WHEN team_id = home_team_id AND home_team_wins = 1 THEN 1
        WHEN team_id = visitor_team_id AND home_team_wins = 0 THEN 1
        ELSE 0 
      END) AS total_wins        
    FROM
      converted_minutes
    GROUP BY
      GROUPING SETS (
        (player_name, team_abbreviation),
        (player_name, season),
        (team_abbreviation)
      )
  ),
  -- Calculate total wins for each team
  top_wins_teams AS (
    SELECT
      team_abbreviation,
      SUM(total_wins) AS total_wins,
      DENSE_RANK() OVER (ORDER BY SUM(total_wins) DESC) AS rank_top_team
    FROM
      aggregate_data
    WHERE
      season = '(overall)'
      AND player_name = '(overall)'
      AND team_abbreviation != '(overall)'
    GROUP BY
      team_abbreviation 
  )
-- Select the team with the most wins
SELECT
  team_abbreviation 
FROM
  top_wins_teams 
WHERE
  rank_top_team = 1
