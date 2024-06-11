-- CREATE TABLE bhautikgandhi.hw5_q2 (
--     player_id BIGINT,
--     team_id BIGINT,
--     season BIGINT,
--     player_name VARCHAR,
--     m_seconds_played BIGINT,
--     total_field_goals_made DOUBLE,
--     total_field_goals_attempted DOUBLE,
--     average_field_goal_percentage DOUBLE,
--     total_three_pointers_made DOUBLE,
--     total_three_pointers_attempted DOUBLE,
--     average_three_point_percentage DOUBLE,
--     total_free_throws_made DOUBLE,
--     total_free_throws_attempted DOUBLE,
--     average_free_throw_percentage DOUBLE,
--     total_offensive_rebounds DOUBLE,
--     total_defensive_rebounds DOUBLE,
--     total_rebounds DOUBLE,
--     total_assists DOUBLE,
--     total_steals DOUBLE,
--     total_blocks DOUBLE,
--     total_turnovers DOUBLE,
--     total_personal_fouls DOUBLE,
--     total_points DOUBLE,
--     average_plus_minus DOUBLE,
--     total_wins DOUBLE
-- )
INSERT INTO hw5_q2
WITH nba_games_unnest AS (
    SELECT 
        game_id,
        team_info.team_id,
        team_info.win,
        season
    FROM 
        bootcamp.nba_games,
        -- creates two rows, one for each team in a game with the result
        UNNEST(ARRAY[
            ROW(home_team_id, home_team_wins),
            ROW(visitor_team_id, CASE WHEN home_team_wins = 1 THEN 0 ELSE 1 END)
        ]) AS team_info (team_id, win)
),
--deduplicate nba_game_details
ranked_nba_game_details AS (
    SELECT
        *,
        --dedupe on game_id, team_id, and player_id
        ROW_NUMBER()
            OVER (PARTITION BY game_id, team_id, player_id)
        AS row_num 
        FROM bootcamp.nba_game_details
),
nba_game_details_deduped AS (
    SELECT
        *
    FROM
        ranked_nba_game_details
    WHERE
        row_num = 1
),
combined as (
    SELECT
        gd.*,
        -- converting VARCHAR minutes played into seconds 
        CASE
            WHEN CARDINALITY(SPLIT(min, ':')) > 1 THEN CAST(
                CAST(SPLIT(min, ':')[1] AS DOUBLE)*60 + CAST(SPLIT(min, ':')[2] AS DOUBLE) AS INTEGER
            )
            ELSE CAST(min as INTEGER)
        END AS m_seconds_played,
        -- getting the season
        g.season,
        -- getting if the team won the game
        g.win
    FROM 
        nba_game_details_deduped gd 
        LEFT JOIN 
            nba_games_unnest g ON
                gd.game_id = g.game_id
                AND
                gd.team_id = g.team_id
)
SELECT 
    player_id,
    team_id,
    season,
    player_name,
    SUM(m_seconds_played) AS total_seconds_played,
    SUM(fgm) AS total_field_goals_made,
    SUM(fga) AS total_field_goals_attempted,
    AVG(fg_pct) AS average_field_goal_percentage,
    SUM(fg3m) AS total_three_pointers_made,
    SUM(fg3a) AS total_three_pointers_attempted,
    AVG(fg3_pct) AS average_three_point_percentage,
    SUM(ftm) AS total_free_throws_made,
    SUM(fta) AS total_free_throws_attempted,
    AVG(ft_pct) AS average_free_throw_percentage,
    SUM(oreb) AS total_offensive_rebounds,
    SUM(dreb) AS total_defensive_rebounds,
    SUM(reb) AS total_rebounds,
    SUM(ast) AS total_assists,
    SUM(stl) AS total_steals,
    SUM(blk) AS total_blocks,
    SUM(to) AS total_turnovers,
    SUM(pf) AS total_personal_fouls,
    SUM(pts) AS total_points,
    AVG(plus_minus) AS average_plus_minus,
    SUM(win) as total_wins
FROM 
    combined
GROUP BY 
    GROUPING SETS (
        (player_id, player_name, team_id),
        (player_id, player_name, season),
        (team_id)
    )