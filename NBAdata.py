from nba_api.stats.static import players
from nba_api.stats.static import teams
from nba_api.stats.endpoints import leaguegamefinder
from nba_api.stats.library.parameters import Season
from nba_api.stats.library.parameters import SeasonType
from nba_api.stats.endpoints import playbyplay

teamsList = teams.get_teams()

#for team in teamsList :
 #   print("insert into Team (TeamFullName, TeamCity, TeamNickname, TeamAbbreviation, TeamID) values ('%s', '%s', '%s', '%s', '%s');" 
  #  % (team["full_name"],team["city"],team["nickname"],team["abbreviation"],team["id"]))


for team in teamsList :
    gamefinder = leaguegamefinder.LeagueGameFinder(team_id_nullable=team["id"],
                            season_nullable=Season.default,
                            season_type_nullable=SeasonType.regular)  
    games_dict = gamefinder.get_normalized_dict()
    games = games_dict["LeagueGameFinderResults"]
    for game in games:
        df = playbyplay.PlayByPlay(game["GAME_ID"]).get_data_frames()[0]
        print(df.head()) #just looking at the head of the data
        

