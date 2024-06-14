 /*
 Write a query (`query_2`) that uses `GROUPING SETS` to perform aggregations of the `nba_game_details` data. Create slices that aggregate along the following combinations of dimensions:
  - player and team
  - player and season
  - team

  */

CREATE Or Replace TABLE mymah592.nba_grouping_sets AS
-- determine level of aggregation based on grouping

SELECT
    CASE
        WHEN GROUPING (gdd.player_name, gdd.team_abbreviation) = 0 THEN 'player_and_team'
        WHEN GROUPING (gdd.player_name, g.season) = 0 THEN 'player_and_season'
        WHEN GROUPING (gdd.team_abbreviation) = 0 THEN 'team'
    END as Aggregation_level,

-- Null handling

    COALESCE(gdd.player_namem 'Overall') as player_name,
    COALESCE(gdd.team_abbreviation, 'Overall') as team,
    COALESCE(Cast(g.season as VARCHAR), 'Overall') as season,
-- aggregate points and games won
    SUM(gdd.pts) as points,
    SUM(
        Case
            When(
                gdd.team_id = g.home_team_id
                and home_team_id = 1
            )
            OR(
                gdd.team_id = g.visitor_team_id
                and home_team_wins = 0
            ) THEN 1
            ELSE 0
        END
    ) as games_won
FROM
    bootcamp.nba_game_details_dedup as gdd
    JOIN bootcamp.nba_games as g on gdd.game_id = g.game_id
GROUP BY
    GROUPING SETS(
        (gdd.player_name, gdd.team_abbreciation),
        (gdd.player_name, g.season),
        (gdd.team_abbreviation)
    )
