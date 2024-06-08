SELECT MAX_BY(player,points)
FROM grouped
WHERE season<>'(all_seasons)' AND player<>'(all_players)'