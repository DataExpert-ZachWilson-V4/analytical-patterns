-- Define the previous season's player data
WITH
  last_season AS (
    SELECT
      player_name,
      height,
      college,
      country,
      draft_year,
      draft_round,
      draft_number,
      seasons,
      current_season,
      years_since_last_active
    FROM
      bootcamp.nba_players
    WHERE
      current_season = 1995
  ),
  -- Define the current season's player data
  this_season AS (
    SELECT
      player_name,
      season,
      college,
      country,
      draft_year,
      draft_round,
      draft_number,
      height,
      age,
      weight,
      gp,
      pts,
      reb,
      ast
    FROM
      bootcamp.nba_player_seasons
    WHERE
      season = 1996
  )
  -- Combine the previous and current season data and determine player states
SELECT
  COALESCE(ls.player_name, ts.player_name) AS player_name,
  COALESCE(ls.height, ts.height) AS height,
  COALESCE(ls.college, ts.college) AS college,
  COALESCE(ls.country, ts.country) AS country,
  COALESCE(ls.draft_year, ts.draft_year) AS draft_year,
  COALESCE(ls.draft_round, ts.draft_round) AS draft_round,
  COALESCE(ls.draft_number, ts.draft_number) AS draft_number,
  -- Construct the seasons array based on the available data
  CASE
    WHEN ts.season IS NOT NULL THEN ARRAY[
      ROW(
        ts.season,
        ts.age,
        ts.weight,
        ts.gp,
        ts.pts,
        ts.reb,
        ts.ast
      )
    ] || COALESCE(ls.seasons, ARRAY[])
    ELSE ls.seasons
  END AS seasons,
  -- Determine if the player is active in the current season
  ts.season IS NOT NULL AS is_active,
  -- Calculate the years since the player was last active
  CASE
    WHEN ts.season IS NOT NULL THEN 0
    ELSE COALESCE(ls.years_since_last_active, 0) + 1
  END AS years_since_last_active,
  -- Set the current season based on the available data
  COALESCE(ts.season, ls.current_season + 1) AS current_season,
  -- Determine the player's state based on the season data
  CASE
    WHEN ls.seasons IS NULL
    AND ts.season IS NOT NULL THEN 'New'
    WHEN ts.season IS NULL
    AND ls.seasons[1] [1] = ls.current_season THEN 'Retired'
    WHEN ts.season IS NULL
    AND ls.seasons[1] [1] < ls.current_season THEN 'Stayed Retired'
    WHEN ts.season IS NOT NULL
    AND ls.seasons[1] [1] = ls.current_season THEN 'Continued Playing'
    WHEN ts.season IS NOT NULL
    AND ls.seasons[1] [1] < ls.current_season THEN 'Returned from Retirement'
    ELSE 'ERROR'
  END AS state
FROM
  last_season ls
  FULL OUTER JOIN this_season ts ON ls.player_name = ts.player_name
ORDER BY
  player_name