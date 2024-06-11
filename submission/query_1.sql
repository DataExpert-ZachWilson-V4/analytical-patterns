--Step 1
CREATE OR REPLACE TABLE dswills94.nba_players_growth_accounting ( --used to track nba player state by season
	player_name VARCHAR, --name of nba player being tracked
	first_active_season INTEGER, --first season active of nba player
	last_active_season INTEGER, --last season active of nba player
	seasons_active ARRAY(INTEGER), --array of row of nba player active season
	seasonal_active_state VARCHAR, --state of nba player by season
	season INTEGER --season used in analysis
)
WITH (
	format = 'PARQUET', --standard format to handle large datasets
	partitioning = ARRAY['season'] --temporal analysis by season array
)

--Step 2
INSERT INTO dswills94.nba_players_growth_accounting
WITH last_season AS ( --create CTE to pull last season data
	SELECT * FROM dswills94.nba_players_growth_accounting
	WHERE season = 1995
),
this_season AS ( --create CTE to pull this season data
	SELECT
		player_name,
		MAX(seasons[1][1]) AS last_active_season,
		MAX(is_active) AS is_active,
		MAX(current_season) AS active_season
	FROM bootcamp.nba_players
	WHERE current_season = 1996
	GROUP BY player_name
),
combined AS (
SELECT
	COALESCE(ls.player_name, ts.player_name) AS player_name,
	COALESCE(ls.first_active_season, ts.last_active_season) AS first_active_season,
	COALESCE(ts.last_active_season, ls.last_active_season) AS last_active_season,
	CASE
		WHEN ls.seasons_active IS NULL THEN ARRAY[ts.last_active_season] --when player start new season, then track new season in array
		WHEN ts.last_active_season IS NULL THEN ls.seasons_active --when player is not playing this season, then pull last seasons active arrys
		WHEN ts.last_active_season = ls.seasons_active[1] THEN ls.seasons_active --when player last active season is same, then pull last active season array to not cause dupe
		ELSE ARRAY[ts.last_active_season] || ls.seasons_active
	END AS seasons_active,
	CASE
		WHEN ls.player_name IS NULL AND ts.player_name IS NOT NULL THEN 'New' --we determine that nba player was not there last season, but is here this season
		WHEN ts.is_active AND (ts.active_season - ls.last_active_season) = 1 THEN 'Continued Playing' --if player is active this season and there is 1 year difference between this season and last active season
		WHEN ts.is_active AND (ts.active_season - ls.last_active_season) > 1 THEN 'Returned from Retirement' --if player is active this season and there is greater than 1 year difference between this season and last active season
		WHEN NOT ts.is_active AND (ts.active_season - ls.last_active_season) = 1 THEN 'Retired' --if player is not active this season and there is 1 year difference between this season and last active season
		ELSE 'Stayed Retired'
		--WHEN NOT ts.is_active AND (ts.active_season - ls.last_active_season) > 1 THEN 'Stayed Retired' --if player is not active this season and there is greater than 1 year difference between this season and last active season
	END AS seasonal_active_state,
	COALESCE(ts.active_season, ls.season + 1) AS season
FROM last_season ls
FULL OUTER JOIN this_season ts --to capture stage changes
	ON ls.player_name = ts.player_name
)
SELECT
	player_name,
	first_active_season,
	last_active_season,
	seasons_active,
	seasonal_active_state,
	season
FROM combined
