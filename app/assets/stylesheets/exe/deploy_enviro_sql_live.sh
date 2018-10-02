find ../lib/sql_views/ *.sql -type f -exec sqlcmd -S 10.104.10.29 -U ro_groundsure -P P3Easy3t!RwL -i {} \;
