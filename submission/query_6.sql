WITH nba_game_details_dedup AS
(
         SELECT   game_id,
                  team_id,
                  team_abbreviation
         FROM     bootcamp.nba_game_details_dedup
         GROUP BY game_id,
                  team_id,
                  team_abbreviation ), combined AS
(
       SELECT games.game_date_est,
              nba_game_details_dedup.team_id,
              nba_game_details_dedup.team_abbreviation,
              CASE
                     WHEN nba_game_details_dedup.team_id = home_team_id
                     AND    home_team_wins = 1 THEN 1
                     WHEN nba_game_details_dedup.team_id = visitor_team_id
                     AND    home_team_wins = 0 THEN 1
                     ELSE 0
              END AS team_wins
       FROM   bootcamp.nba_games games
       JOIN   nba_game_details_dedup
       ON     games.game_id = nba_game_details_dedup.game_id), wins_in_90 AS
(
         SELECT   team_id,
                  team_abbreviation,
                  sum(team_wins) OVER (partition BY team_id ORDER BY game_date_est rows BETWEEN 89 PRECEDING AND      CURRENT row ) AS wins
         FROM     combined )
SELECT   team_id,
         team_abbreviation,
         max(wins) AS max_wins
FROM     wins_in_90
GROUP BY team_id,
         team_abbreviation
ORDER BY max_wins DESC limit 1