--Query to group nba game details into grouped sets by players name, team and session
CREATE OR REPLACE TABLE amaliah21315.nba_game_details_grouped AS WITH combined AS (
        SELECT COALESCE(gmdt.player_name, 'N/A') AS player_name,-- set null player name to N/A
            COALESCE(gmdt.team_abbreviation, 'N/A') AS team_abbreviation,
            COALESCE(CAST(g.season AS Varchar), 'N/A') AS season,
            gmdt.ftm as free_throws_made,
            gmdt.fgm as field_goals_made,
            gmdt.pts as points,
            CASE
                WHEN gmdt.team_id = g.home_team_id THEN home_team_wins = 1 -- set team won if hometeam is current team
                ELSE home_team_wins = 0
            END AS team_won
        FROM bootcamp.nba_game_details gmdt
            JOIN bootcamp.nba_games g ON g.game_id = gmdt.game_id
    )
SELECT COALESCE(player_name, '(overall)') AS player_name,
    COALESCE(team_abbreviation, '(overall)') AS team_abbreviation,
    COALESCE(CAST(season as Varchar), '(overall)') AS season,
    SUM(free_throws_made) as free_throws_made,
    SUM(field_goals_made) as field_goals_made,
    SUM(points) as total_points,
    SUM(IF(team_won = true, 1, 0)) as total_games_won,-- Calculate games won
    SUM(IF(team_won = false, 1, 0)) as total_games_lost,--Calculate gamaes lost
    SUM(IF(team_won = true, 1, 0)) * 100.0 / (
        SUM(IF(team_won = true, 1, 0)) + SUM(IF(team_won = false, 1, 0))
    ) AS percentage_won, -- Calculate percentage of games won
    CASE
        WHEN GROUPING(player_name, team_abbreviation) = 0 THEN 'player_team'
        WHEN GROUPING(player_name, season) = 0 THEN 'player_season'
        WHEN GROUPING(team_abbreviation) = 0 THEN 'team_only'
    END AS grouping_category
FROM combined
GROUP BY GROUPING SETS (
        (player_name, team_abbreviation),
        (player_name, season),
        (team_abbreviation)
    ) 