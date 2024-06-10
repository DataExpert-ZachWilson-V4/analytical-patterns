
-- CTE to prepare nba game details with a flag indicating if a player scored over 10 points
with nba_games_details as (
  select
    gd.game_id,                                 -- Select game ID
    gd.player_name,                             -- Select player name
    g.game_date_est as game_date,               -- Select game date
    gd.pts > 10 as player_scored_over_10        -- Flag indicating if player scored over 10 points
  from bootcamp.nba_game_details_dedup as gd    -- From the deduplicated game details table
  inner join bootcamp.nba_games as g            -- Inner join with games table on game ID
    on gd.game_id = g.game_id
),

lagged as (
  select
    *,
    lag(player_scored_over_10, 1) over (        -- Get the flag for the previous game
      partition by player_name                  -- Partition by player name
      order by game_date                        -- Order by game date
    ) as prev_game_scored_over_10               -- Alias for the previous game's score flag
  from nba_games_details
)
-- Final query to count the consecutive games where LeBron James scored over 10 points
select
  player_name,      -- Select player name
  sum(if(           -- Sum up the consecutive games scoring over 10 points
    player_scored_over_10 and prev_game_scored_over_10,   -- Check if both current and previous game scores are over 10 points
    1,              -- Count as 1 if the condition is met
    0               -- Count as 0 otherwise
  )) as consecutive_games_scored_over_10    -- Alias for the consecutive games count
from lagged
where player_name = 'LeBron James'          -- Filter to include only LeBron James
group by 1                                  -- Group by player name
