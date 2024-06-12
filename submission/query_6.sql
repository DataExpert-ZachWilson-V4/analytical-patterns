with
teams as (
    select distinct
        team_id,
        team_abbreviation as nickname
    from bootcamp.nba_game_details
),

deduped_games as (
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

games as (
    select
        game_date_est,
        home_team_id as team_id,
        home_team_wins as is_win
    from
        deduped_games
    union
    select
        game_date_est,
        visitor_team_id as team_id,
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
        game_date_est as window_end,
        game_date_est - interval '90' day as window_start,
        sum(is_win) over (
            partition by
                team_id
            order by
                game_date_est
            rows between 89 preceding and current row
        ) as n_wins
    from
        games
)

select
    t.nickname as team_name,
    max_by(w.window_start, w.n_wins) as window_start,
    max_by(w.window_end, w.n_wins) as window_end,
    max(w.n_wins) as max_wins_90_days
from
    wins_90_days as w
inner join
    teams as t
    on w.team_id = t.team_id
group by
    t.nickname
