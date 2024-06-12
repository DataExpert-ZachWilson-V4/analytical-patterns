--
-- Query 5: Which team has won the most games?
--
-- team_abbreviation	max_wins
-- SAS	                1182
--

SELECT
    team_abbreviation,
    MAX(team_wins) AS max_wins
FROM
    jlcharbneau.nba_grouping_sets
WHERE
    aggregation_level = 'team'
GROUP BY
    team_abbreviation
ORDER BY
    max_wins DESC
LIMIT 1