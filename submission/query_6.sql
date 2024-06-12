with deduped_games as (
        select
            game_date_est,
            home_team_id,
            visitor_team_id,
            home_team_wins
        from
            bootcamp.nba_games
        group by
            game_date_est,
            home_team_id,
            visitor_team_id,
            home_team_wins
    ),
    -- include games from both teams
    games_both_perspectives as (
        select
            game_date_est,
            home_team_id as team_id,
            case
                when home_team_wins = 1 then 0
                when home_team_wins = 0 then 1
            end as is_win
        from
            deduped_games
    ),
    wins_90_days as (
    select
        team_id,
        game_date_est - interval '90' day as window_start,
        game_date_est as window_end,
        sum(is_win) over (
            partition by
                team_id
            order by
                game_date_est ROWS BETWEEN 89 PRECEDING AND CURRENT ROW -- get 90 days wins
        ) as n_wins
    from
        games_both_perspectives
    )
select
    team_abbreviation as team_name,
    max_by(win.window_start, win.n_wins) as window_start,
    max_by(win.window_end, win.n_wins) as window_end,
    max(win.n_wins) max_wins_over_90_days
from
    wins_90_days win
join
    bootcamp.nba_game_details_dedup gd on win.team_id = gd.team_id
GROUP BY
    team_abbreviation
