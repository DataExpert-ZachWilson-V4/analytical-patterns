WITH detailed_wins AS (
    SELECT  game_date_est,
            game_id,
            home_team_id,
            visitor_team_id,
            home_team_wins,
            LAG(home_team_wins) OVER (PARTITION BY home_team_id ORDER BY game_date_est) AS won_prev,
            COUNT(game_id) OVER(PARTITION BY home_team_id ORDER BY game_date_est) AS games_played

    FROM bootcamp.nba_games
    ),

games_streak AS (
    SELECT  game_date_est,
            game_id,
            home_team_id,
            games_played,
            COALESCE(won_prev, 0) AS won_prev,
            home_team_wins,
            SUM(
              CASE
                  WHEN COALESCE(won_prev, 0) + home_team_wins = 0 THEN 0
                  WHEN COALESCE(won_prev, 0) > home_team_wins THEN 1
                  ELSE 0
              END)
          OVER(PARTITION BY home_team_id ORDER BY game_date_est ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS streak
      FROM detailed_wins
      ),
winning_streak_count AS (
SELECT
    *,
    SUM(home_team_wins) OVER(PARTITION BY home_team_id, streak ORDER BY game_date_est) AS streak_ct
  FROM games_streak),

grouped_wins AS(
    SELECT
        home_team_id,
        MAX(streak_ct) AS longest_streak
      FROM winning_streak_count
      WHERE games_played >= 90
      GROUP BY 1
      )
SELECT home_team_id, longest_streak
FROM grouped_wins
ORDER BY longest_streak DESC
LIMIT 1