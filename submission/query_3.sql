-- Select the relevant columns to identify the player and team with the most points
select
  player,                           -- Select the player name
  team,                             -- Select the team abbreviation
  total_points                      -- Select the total points scored
from sumanacheera.nba_game_details_groupingsets     -- From the aggregated results table
where grouping_type = 'player_team'                 -- Filter to only include 'player_team' groupings
order by total_points desc                          -- Order the results by total points in descending order to find the highest scorer
