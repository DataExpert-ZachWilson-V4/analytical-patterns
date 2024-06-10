
-- CTE to prepare nba game details with win status
with nba_games_details as (
  select distinct
    gd.game_id,                     -- Select game ID
    gd.team_abbreviation,           -- Select team abbreviation
    g.game_date_est as game_date,   -- Select game date
    if(
      (gd.team_id = g.home_team_id and g.home_team_wins = 1)
      or (gd.team_id = g.visitor_team_id and g.home_team_wins = 0),
      1,   -- Mark as win if the team won the game
      0    -- Mark as loss otherwise
    ) as wins
  from bootcamp.nba_game_details_dedup as gd     -- From the deduplicated game details table
  inner join bootcamp.nba_games as g             -- Inner join with games table on game ID
    on gd.game_id = g.game_id
),
-- CTE to calculate the 90-game win streak for each team
stretch as (
  select
    *,  -- Select all columns
    sum(wins) over (                    -- Calculate the sum of wins over a 90-game window
      partition by team_abbreviation    -- Partition by team
      order by game_date                -- Order by game date
      rows between 89 preceding and current row     -- Define a 90-game window
    ) as ninety_day_win_streak                      -- Alias for the 90-game win streak
  from nba_games_details
)
-- Final query to select the team with the highest 90-game win streak
select
  team_abbreviation as team,                                        -- Select team abbreviation and alias it as team
  max_by(game_date, ninety_day_win_streak) as end_stretch_date,     -- Select the end date of the stretch with the highest wins
  max(ninety_day_win_streak) as wins_90_days_stretch                -- Select the maximum number of wins in any 90-game stretch
from stretch
group by 1                                                          -- Group by team
order by 3 desc, 2 desc                                             -- Order by the number of wins in descending order, then by end date in descending order
