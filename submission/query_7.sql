WITH combined as (
  SELECT
    a.player_name
    , a.team_id
    , a.team_abbreviation
    , a.pts -- 0 points means a player played in game without scoring, a null indicates they didn't play
    , a.min --to determine for sure if a player played a game even without any points
    , b.home_team_id
    , b.visitor_team_id
    , b.season
    , b.game_id
    , b.home_team_wins
    , b.game_date_est
  FROM saismail.nba_game_details_deduped a
  JOIN bootcamp.nba_games b on a.game_id = b.game_id
),
lebrons_games AS (
    SELECT
        team_abbreviation,
        player_name,
        game_date_est,
        CASE WHEN pts > 10 THEN 1 ELSE 0 END AS scored_over_10,
        ROW_NUMBER() OVER (ORDER BY game_date_est) AS game_number
    FROM
        combined
    WHERE
        player_name = 'LeBron James'
),
streaks AS (
    SELECT
        game_date_est,
        scored_over_10,
        game_number,
        game_number - ROW_NUMBER() OVER (PARTITION BY scored_over_10 ORDER BY game_number) AS streak_id
    FROM
        lebrons_games
)
SELECT
    COUNT(*) AS games_in_a_row
FROM
    streaks
WHERE
    scored_over_10 = 1
GROUP BY
    streak_id
ORDER BY
    games_in_a_row DESC
LIMIT 1