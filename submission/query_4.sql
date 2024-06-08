WITH game_details AS (
	SELECT
		d.game_id,
		d.player_id,
		d.player_name,
		d.team_id,
		d.team_abbreviation,
		COALESCE(d.pts,0) as pts,
		g.season,
		-- We don't really have a count of games won per team: we only know if the home team won. If the home team didn't win, it's either a tie or the visiting team won.
		g.team_id_home,
		g.home_team_wins
	FROM bootcamp.nba_game_details d
	JOIN bootcamp.nba_games g
	ON d.game_id = g.game_id
	
	-- Removing duplicates from the original table
	GROUP BY d.game_id, d.player_id, d.player_name, d.team_id, d.team_abbreviation, d.pts, g.season, g.team_id_home, g.home_team_wins
),
grouped AS (
	SELECT
		COALESCE(player_name,'(all_players)') as player,
		COALESCE(team_abbreviation,'(all_teams)') as team,
		COALESCE(CAST(season AS VARCHAR),'(all_seasons)') as season,
		SUM(pts) as points
	FROM game_details
	GROUP BY GROUPING SETS (
		(player_name, team_abbreviation),
		(player_name, season),
		(team_abbreviation)
	)
)
  
SELECT MAX_BY(player,points)
FROM grouped
WHERE season<>'(all_seasons)' AND player<>'(all_players)'
