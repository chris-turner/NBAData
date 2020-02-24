from nba_api.stats.static import players
from nba_api.stats.static import teams
from nba_api.stats.endpoints import leaguegamefinder
from nba_api.stats.endpoints import teamgamelog
from nba_api.stats.library.parameters import Season
from nba_api.stats.library.parameters import SeasonType
from nba_api.stats.endpoints import playbyplay
from pandas import DataFrame

teamsList = teams.get_teams()

for team in teamsList :
    print("insert into Team (TeamFullName, TeamCity, TeamNickname, TeamAbbreviation, TeamID) values ('%s', '%s', '%s', '%s', '%s');" 
    % (team["full_name"],team["city"],team["nickname"],team["abbreviation"],team["id"]))
    gamefinder = leaguegamefinder.LeagueGameFinder(team_id_nullable=team[0]["id"],
                        season_nullable=Season.default,
                        season_type_nullable=SeasonType.regular)
    gameLog = teamgamelog.TeamGameLog(team_id = teamsList[0]["id"])
    glDf = gameLog.get_data_frames()[0]




gameLog = teamgamelog.TeamGameLog(team_id = teamsList[0]["id"])
gl = gameLog.get_data_frames()[0]
games_dict = gamefinder.get_normalized_dict()
games = games_dict["LeagueGameFinderResults"]
df = playbyplay.PlayByPlay(games[1]["GAME_ID"]).get_data_frames()[0]



gl.to_excel("output2.xlsx")  

        


#for team in teamsList :
#    gamefinder = leaguegamefinder.LeagueGameFinder(team_id_nullable=team["id"],
#                            season_nullable=Season.default,
#                            season_type_nullable=SeasonType.regular)  
#    games_dict = gamefinder.get_normalized_dict()
#    games = games_dict["LeagueGameFinderResults"]
#    for game in games:
#        df = playbyplay.PlayByPlay(game["GAME_ID"]).get_data_frames()[0]
#        print(df.head()) #just looking at the head of the data
        

