-- Use GROUPING SETS to perform aggregations of the nba_game_details data
CREATE OR REPLACE TABLE akshayjainytl54781.nba_grouping_sets AS
SELECT
    -- grouping set determines what's being aggregated
    CASE
        WHEN GROUPING (gdd.player_name, gdd.team_abbreviation) = 0 THEN 'player_and_team'
        WHEN GROUPING (gdd.player_name, g.season) = 0 THEN 'player_and_season'
        WHEN GROUPING (gdd.team_abbreviation) = 0 THEN 'team'
    END as aggregation_level,
    COALESCE(gdd.player_name, 'Overall') AS player_name,
    COALESCE(gdd.team_abbreviation, 'Overall') AS team,
    -- aggregation
    SUM(gdd.pts) AS points,
    COALESCE(CAST(g.season AS VARCHAR), 'Overall') AS season,
    -- Number of games won
    SUM(
        CASE
            WHEN (
                gdd.team_id = g.home_team_id
                AND home_team_wins = 1
            )
            OR (
                gdd.team_id = g.visitor_team_id
                AND home_team_wins = 0
            ) THEN 1
            ELSE 0
        END
    ) AS games_won
FROM
    bootcamp.nba_game_details_dedup AS gdd
    JOIN bootcamp.nba_games AS g ON gdd.game_id = g.game_id
GROUP BY
    GROUPING SETS (
        (gdd.player_name, gdd.team_abbreviation),
        (gdd.player_name, g.season),
        (gdd.team_abbreviation)
    )