with
    team_win_counts as (
        select
            team_id,
            team_abbreviation,
            sum(
                case
                    when n_win > 0 then 1 -- if anyone won => team won; n_wins is a count which depends on number of team players but we just want value of 1 if team won; 
                    when n_win = 0 then 0 -- no one won => team lost
                end
            ) as n_team_wins
        from
            sarneski44638.nba_grouping_sets
        where
            level_id = 'game_team_level'
        group by
            team_id,
            team_abbreviation
    )
select
    max_by(team_id, n_team_wins) as team_id,
    max_by(team_abbreviation, n_team_wins) as team_abbreviation,
    max(n_team_wins) as max_team_wins
from
    team_win_counts