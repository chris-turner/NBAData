from nba_api.stats.static import players
from nba_api.stats.static import teams

teamsList = teams.get_teams()

for team in teamsList :
    print("insert into Team (TeamFullName, TeamCity, TeamNickname, TeamAbbreviation, TeamID) values ('%s', '%s', '%s', '%s', '%s');" 
    % (team["full_name"],team["city"],team["nickname"],team["abbreviation"],team["id"]))