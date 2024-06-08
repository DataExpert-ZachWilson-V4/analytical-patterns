--Using the aggregated query from query_2, find the top record in the (team_abbreviation) grouping ordering by SUM(team_wins) descending
--This is the use case for which we needed the team_wins column, which is aggregated at the team grain
WITH nba_game_details_full AS (
	SELECT team_id,
		game_id,
		team_abbreviation,
		player_name,
		fgm,
		fga,
		fg3m,
		fg3a,
		ftm,
		fta,
		oreb,
		dreb,
		reb,
		ast,
		stl,
		blk,
		to,
		pf,
		pts,
		ROW_NUMBER() OVER (PARTITION BY game_id, team_id, player_id) AS row_number
	FROM bootcamp.nba_game_details 
), 
nba_game_details_deduped AS (
	SELECT team_id,
		game_id,
		team_abbreviation,
		player_name,
		fgm,
		fga,
		fg3m,
		fg3a,
		ftm,
		fta,
		oreb,
		dreb,
		reb,
		ast,
		stl,
		blk,
		to,
		pf,
		pts,
		ROW_NUMBER() OVER (PARTITION BY team_id, game_id ORDER BY player_name) AS player_order
	FROM nba_game_details_full
	WHERE row_number = 1
),
nba_games_full AS (
	SELECT game_id,
		season,
		team_id_home,
		home_team_wins,
		ROW_NUMBER() OVER (PARTITION BY game_id) AS row_number
	FROM bootcamp.nba_games
),
nba_games_deduped AS (
	SELECT game_id,
		season,
		team_id_home,
		home_team_wins
	FROM nba_games_full
	WHERE row_number = 1
),
nba_games_aggregated AS (
	SELECT COALESCE(player_name,'(overall)') AS player_name,
		COALESCE(team_abbreviation,'(overall)') AS team_abbreviation,
		COALESCE(CAST(season AS VARCHAR),'(overall)') AS season,
		SUM(fgm) AS fgm,
		SUM(fga) AS fga,
		CASE WHEN SUM(fga) > 0 THEN SUM(fgm) / SUM(fga) END AS fgpct,
		SUM(fg3m) AS fg3m,
		SUM(fg3a) AS fg3a,
		CASE WHEN SUM(fg3a) > 0 THEN SUM(fg3m) / SUM(fg3a) END AS fg3pct,
		SUM(ftm) AS ftm,
		SUM(fta) AS fta,
		CASE WHEN SUM(fta) > 0 THEN SUM(ftm) / SUM(fta) END AS ftpct,
		SUM(oreb) AS oreb,
		SUM(dreb) AS dreb,
		SUM(reb) AS reb,
		SUM(ast) AS ast,
		SUM(stl) AS stl,
		SUM(blk) AS blk,
		SUM(to) AS to,
		SUM(pf) AS pf,
		SUM(pts) AS pts,
		SUM(CASE WHEN ngd.team_id = ng.team_id_home THEN ng.home_team_wins ELSE 1 - ng.home_team_wins END) AS player_wins,
		SUM(CASE WHEN ngd.player_order = 1 THEN CASE WHEN ngd.team_id = ng.team_id_home THEN ng.home_team_wins ELSE 1 - ng.home_team_wins END END) AS team_wins
	FROM nba_game_details_deduped ngd
		JOIN nba_games_deduped ng ON ngd.game_id = ng.game_id
	GROUP BY GROUPING SETS (
		(player_name, team_abbreviation),
		(player_name, season),
		(team_abbreviation)
	)
)
SELECT team_abbreviation,
	SUM(team_wins) AS total_team_wins
FROM nba_games_aggregated
WHERE season = '(overall)'
	AND player_name = '(overall)'
	AND team_abbreviation != '(overall)'
GROUP BY team_abbreviation
ORDER BY SUM(team_wins) DESC
LIMIT 1