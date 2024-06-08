-- Join nba_game_details with nba_games to get all fields in one table
-- Cast data types as needed

WITH combined AS (
    SELECT
    CAST(g.game_id AS BIGINT) AS game_id,
    gd.team_id,
    gd.player_id,
    gd.team_abbreviation AS team_abbreviation,
    gd.player_name AS player_name,
    CASE
        WHEN CARDINALITY(SPLIT(MIN, ':')) > 1 
        THEN CAST(
            CAST(SPLIT(MIN, ':') [1] AS DOUBLE) * 60 + CAST(SPLIT(MIN, ':') [2] AS DOUBLE) AS INTEGER
        )
        ELSE CAST(MIN AS INTEGER) 
    END AS m_seconds_played, 
    CAST(fgm AS DOUBLE) AS m_field_goals_made,
    CAST(fga AS DOUBLE) AS m_field_goals_attempted,
    CAST(fg3m AS DOUBLE) AS m_3_pointers_made,
    CAST(fg3a AS DOUBLE) AS m_3_pointers_attempted,
    CAST(ftm AS DOUBLE) AS m_free_throws_made,
    CAST(fta AS DOUBLE) AS m_free_throws_attempted,
    CAST(oreb AS DOUBLE) AS m_offensive_rebounds,
    CAST(dreb AS DOUBLE) AS m_defensive_rebounds,
    CAST(reb AS DOUBLE) AS m_rebounds,
    CAST(ast AS DOUBLE) AS m_assists,
    CAST(stl AS DOUBLE) AS m_steals,
    CAST(blk AS DOUBLE) AS m_blocks,
    CAST(TO AS DOUBLE) AS m_turnovers,
    CAST(pf AS DOUBLE) AS m_personal_fouls,
    CAST(pts AS DOUBLE) AS m_points,
    CAST(plus_minus AS DOUBLE) AS m_plus_minus,
    g.game_date_est AS game_date,
    g.season AS season,
    CASE
        WHEN gd.team_id = g.home_team_id THEN home_team_wins = 1
        ELSE home_team_wins = 0
    END AS team_did_win
    FROM bootcamp.nba_games g -- used nbs_games dataset to get season
    JOIN bootcamp.nba_game_details gd ON g.game_id = gd.game_id
)

-- Aggregate data, Group by combinations of  player, team, and season
SELECT COALESCE(player_name, '(all_players)') as player_name,
    COALESCE(team_abbreviation, '(all_teams)') as team_abbreviation,
    season,
    SUM(m_field_goals_made) AS total_field_goals_made,
    SUM(m_field_goals_attempted) AS total_field_goals_attempted,
    SUM(m_3_pointers_made) AS total_3_pointers_made,
    SUM(m_3_pointers_attempted) AS total_3_pointers_attempted,
    SUM(m_free_throws_made) AS total_free_throws_made,
    SUM(m_free_throws_attempted) AS total_free_throws_attempted,
    SUM(m_offensive_rebounds) AS total_offensive_rebounds,
    SUM(m_defensive_rebounds) AS total_defensive_rebounds,
    SUM(m_rebounds) AS total_rebounds,
    SUM(m_assists) AS total_assists,
    SUM(m_steals) AS total_steals,
    SUM(m_blocks) AS total_blocks,
    SUM(m_turnovers) AS total_turnovers,
    SUM(m_personal_fouls) AS total_personal_fouls,
    SUM(m_points) AS total_points,
    SUM(m_plus_minus) AS total_plus_minus,
    CASE 
        WHEN player_name != '(all_players)' AND team_abbreviation != '(all_teams)' THEN 'player_team_aggregate' 
        WHEN player_name != '(all_players)' AND season IS NOT NULL THEN 'player_season_aggregate'
        WHEN team_abbreviation != '(all_teams)' THEN 'team_aggregate'
    END AS agg_type
FROM combined
GROUP BY 
  GROUPING SETS (
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation)
  )