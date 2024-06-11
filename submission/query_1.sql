WITH yesterday as (
	SELECT *
	FROM aasimsani0586451.nba_player_changes
	WHERE season = 2001
),
today as (
	SELECT 
		player_name,
		current_season
	FROM bootcamp.nba_players
	WHERE current_season = 2001 AND is_active = true
),

-- Get the first and last season a player was active, the seasons they were active, 
-- and the status of the player in the current season.
day_delta as (
	SELECT 
		COALESCE(yd.player_name, td.player_name) as player_name,
		COALESCE(yd.first_season_active, td.current_season) as first_season_active,
		COALESCE(td.current_season, yd.last_season_active) as last_season_active,
		-- Create an array of seasons a player was active
		CASE
			WHEN yd.seasons_active IS NULL THEN ARRAY [td.current_season]
			WHEN td.current_season IS NULL THEN yd.seasons_active
			ELSE yd.seasons_active || ARRAY [td.current_season]
		END AS seasons_active,
		yd.last_season_active as active_previous_season,
		td.current_season as active_season,
		2001 as season
	FROM yesterday yd
		FULL OUTER JOIN today td ON yd.player_name = td.player_name
)
SELECT 
	player_name,
	first_season_active,
	last_season_active,
	seasons_active,
	-- Determine the status of the player in the current season
	CASE
		WHEN active_season - first_season_active = 0 THEN 'New'
		WHEN active_season IS NULL AND season - last_season_active = 1 THEN 'Retired'
		WHEN active_season - last_season_active = 0 THEN 'Continued Playing'
		WHEN active_season - active_previous_season > 1 THEN 'Returned from Retirement'
		ELSE 'Stayed Retired'
	END AS season_status,
	season
FROM day_delta
