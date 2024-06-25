-- Write a query (`query_6`) that uses window functions on `nba_game_details` to answer the question:
-- "What is the most games a single team has won in a given 90-game stretch?"

-- most games a team has won in a 90-game stretch, calculated as --
-- subtract the cumulative wins as of the current game from the cumulative_wins as
-- of the game which occurred 90 games in the past.

-- team_abbreviation	max_wins_over_90_games
-- GSW	                    80

with
    nba_game_details_deduped as (
	    select distinct
	        game_id, team_id, team_abbreviation
	    from bootcamp.nba_game_details
    ),
    combined as (
        select
            gd.team_id,
            gd.game_id,
            gd.team_abbreviation,
            g.game_date_est,
            -- window function to calculate cumulative wins for each team
            SUM(
                case
                    when gd.team_id = g.team_id_home
                        then g.home_team_wins
                    else 1 - g.home_team_wins
                end
            ) over (partition by gd.team_id, gd.team_abbreviation order by g.game_date_est) as cumulative_wins
	    from
	        nba_game_details_deduped gd join bootcamp.nba_games g on gd.game_id = g.game_id
    ),
    cumulated_wins as (
        select
            team_id,
            game_id,
            team_abbreviation,
            cumulative_wins - (
                LAG(cumulative_wins, 90, 0) over (partition by team_id, team_abbreviation order by game_date_est)
            ) as rolling_90_day_wins
        from
            combined
    )
select
    team_abbreviation,
    rolling_90_day_wins
from
    cumulated_wins
order by
    rolling_90_day_wins desc
limit 1
