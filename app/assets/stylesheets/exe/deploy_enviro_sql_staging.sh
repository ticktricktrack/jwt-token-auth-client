find ../lib/sql_views/ *.sql -type f -exec sqlcmd -S 10.104.10.8 -U dba_rs -P Password1 -i {} \;
