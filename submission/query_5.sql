/*
Write a query (query_5) to answer: 
"Which team has won the most games"
*/

WITH team_wins AS(
    SELECT 
        team_abbreviation,
        sum(games_won) AS game_wins
    FROM danieldavid.nba_game_details_grouped
    WHERE aggregation_level = 'player_and_team'
    GROUP BY team_abbreviation
)
SELECT team_abbreviation, game_wins
FROM team_wins
WHERE game_wins = (
    SELECT max(game_wins) FROM team_wins
)