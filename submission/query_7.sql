WITH nba_game_details_dedup AS (
    SELECT
        game_id,
        team_id,
        team_abbreviation,
        player_id,
        player_name,
        pts,
        ROW_NUMBER() OVER (PARTITION BY player_id, game_id, team_id ORDER BY player_id, game_id, team_id) AS rnk
    FROM bootcamp.nba_game_details
),
nba_details AS (
    SELECT 
        game_id,
        team_id,
        team_abbreviation,
        player_id,
        player_name,
        pts 
    FROM nba_game_details_dedup
    WHERE rnk = 1
),
nba_games_dedup AS (
    SELECT 
        game_id,
        game_date_est,
        ROW_NUMBER() OVER (PARTITION BY game_id ORDER BY game_id) AS rnk
    FROM bootcamp.nba_games
),
nba_games AS (
    SELECT 
        game_id,
        game_date_est
    FROM nba_games_dedup
    WHERE rnk = 1 -- Deduping the nba_games data
),
preprep AS (
    SELECT
        player_name,
        ng.game_date_est,
        nd.pts,
        CASE WHEN nd.pts > 10.0 THEN 1 ELSE 0 END AS pts_threshold
    FROM nba_details nd
    JOIN nba_games ng ON nd.game_id = ng.game_id
    WHERE player_name = 'LeBron James'
),
Streaks AS (
    SELECT
        player_name,
        game_date_est,
        pts_threshold,
        SUM(CASE WHEN pts_threshold = 0 THEN 1 ELSE 0 END) OVER (ORDER BY game_date_est) AS reset_counter -- resetting the counter when the threshold points is less than 10
    FROM preprep
),
FinalStreaks AS (
    SELECT
        player_name,
        game_date_est,
        pts_threshold,
        SUM(CASE WHEN pts_threshold = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY reset_counter ORDER BY game_date_est) AS streak_10_pts -- Summing up the games for the reset group
    FROM Streaks
)
SELECT 
    Max(streak_10_pts) As streak_10_pts
FROM FinalStreaks