-- Write a query (`query_7`) that uses window functions on `nba_game_details` to answer the question:
-- "How many games in a row did LeBron James score over 10 points a game?"

-- player_name	max_streak_length
-- LeBron James	974

with
    -- CTE of lebron james 10 point games
    lebron_10_points_games as (
        select *,
        case
            when pts > 10
                then 1
            else 0
        end scored_over_10_points
    from bootcamp.nba_game_details
    where player_name = 'LeBron James'
    ),
    -- calculate streaks w/ window function
    streaks as (
        select
            *,
            -- get reset_streak when a game with <= 10 points is encountered
            SUM(
                case
                    when scored_over_10_points = 0
                        then 1
                    else 0
                end
            ) over (
                partition by player_name
                order by game_id
                rows between unbounded preceding and current row
            ) as reset_streak -- this creates a cumulative sum to identify streaks
        from
            lebron_10_points_games
    ),
    -- calculate length of each streak using row number
    streak_lengths as (
        select
            player_name,
            game_id,
            pts,
            scored_over_10_points,
            reset_streak,
            ROW_NUMBER() over (
                partition by player_name, reset_streak
                order by game_id
            ) as streak_length -- numbering rows within each streak
        from
            streaks
    )
select
    player_name,
    MAX(streak_length) as max_streak_length
from streak_lengths
group by player_name
