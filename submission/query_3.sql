--
-- Which player scored the most points playing for a single team?
--
-- player_name	team_abbreviation	max_points
-- LeBron James	CLE	28314
--
SELECT
    player_name,
    team_abbreviation,
    MAX(total_points) AS max_points
FROM
    vzucher.nba_grouping_sets
WHERE
    aggregation_level = 'player_team'
GROUP BY
    player_name,
    team_abbreviation
ORDER BY
    max_points DESC
LIMIT 1