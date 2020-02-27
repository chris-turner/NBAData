from nba_api.stats.static import players
from nba_api.stats.static import teams
from nba_api.stats.endpoints import leaguegamefinder
from nba_api.stats.endpoints import teamgamelog
from nba_api.stats.endpoints import leaguegamelog
from nba_api.stats.library.parameters import Season
from nba_api.stats.library.parameters import SeasonType
from nba_api.stats.endpoints import playbyplay
from pandas import DataFrame
import pandas as pd
import pyodbc as pyodbc

# cursor.execute(
#conn.commit()

#glDf.to_excel("teamdl.xlsx")       

# gamefinder = leaguegamefinder.LeagueGameFinder(team_id_nullable=team["id"],
#                     season_nullable=Season.default,
#                     season_type_nullable=SeasonType.regular)
# gameLog = teamgamelog.TeamGameLog(team_id = teamsList[0]["id"])
# games_dict = gamefinder.get_normalized_dict()
# games = games_dict["LeagueGameFinderResults"]
# df = playbyplay.PlayByPlay(games[1]["GAME_ID"]).get_data_frames()[0]

#gl.to_excel("output2.xlsx")  

#for team in teamsList :
#    gamefinder = leaguegamefinder.LeagueGameFinder(team_id_nullable=team["id"],
#                            season_nullable=Season.default,
#                            season_type_nullable=SeasonType.regular)  
#    games_dict = gamefinder.get_normalized_dict()
#    games = games_dict["LeagueGameFinderResults"]
#    for game in games:
#        df = playbyplay.PlayByPlay(game["GAME_ID"]).get_data_frames()[0]
#        print(df.head()) #just looking at the head of the data
        
def insertTeamsToDB():
    teamsList = teams.get_teams()

    for team in teamsList :
        runAndCommitSQL("insert into Team (TeamFullName, TeamCity, TeamNickname, TeamAbbreviation, TeamID) values ('%s', '%s', '%s', '%s', '%s');" 
        % (team["full_name"],team["city"],team["nickname"],team["abbreviation"],team["id"]))

def getGameData(dateFrom):

    if dateFrom != '':
        gameLog = leaguegamelog.LeagueGameLog(date_from_nullable=dateFrom)
    else:
        gameLog = leaguegamelog.LeagueGameLog()
    glDf = gameLog.get_data_frames()[0]
        #loop through game log
    insertStatements = ""
    updateStatements = ""
    for i, gameRow in glDf.iterrows():
        sqlRow = getSQLDataInDF("SELECT * from NBA_game where gameID = '" + gameRow['GAME_ID'] + "'")
            # if gameID already exists, insert current team id to whichever of homeTeamID and awayTeamID is null 
        if not sqlRow.empty:
            if sqlRow.iloc[0]['homeTeamID'] is None:
                if sqlRow.iloc[0]['awayTeamID'] != str(gameRow["TEAM_ID"]):
                    runAndCommitSQL("update NBA_game set homeTeamID = '%s' where gameID = '%s'; "
                    % (gameRow["TEAM_ID"], gameRow['GAME_ID']))
            elif sqlRow.iloc[0]['awayTeamID'] is None:
                if sqlRow.iloc[0]['homeTeamID'] != str(gameRow["TEAM_ID"]):
                    runAndCommitSQL("update NBA_game set awayTeamID = '%s' where gameID = '%s'; "
                    % (gameRow["TEAM_ID"], gameRow['GAME_ID']))
            else:
                print('neither team for gameID is null')

            
        #if it does not exist, insert to table with one team id null    
        else:
            matchup = gameRow['MATCHUP']

            if matchup[4] == '@':
                teamIDinDB = 'awayTeamID'
            elif matchup[4] == 'v':
                teamIDinDB = 'homeTeamID'
            else:
                raise ValueError('Error: can\'t determine home or away from matchup')

            runAndCommitSQL("insert into NBA_game (gameID, "+ teamIDinDB + ", gameDate, seasonID) values ('%s', '%s', '%s', '%s');" 
            % (gameRow['GAME_ID'],gameRow["TEAM_ID"],gameRow["GAME_DATE"],gameRow["SEASON_ID"] ))

def runAndCommitSQL(sqlStatement):
    server = 'IHMNYC01CXT\\SQLEXPRESS' 
    database = 'TestDB' 
    #username = 'myusername' 
    #password = 'mypassword' 
    #conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';Trusted_Connection=yes;')
    cursor = conn.cursor()
    cursor.execute(sqlStatement)
    conn.commit()

def getSQLDataInDF(sqlQuery):
    server = 'IHMNYC01CXT\\SQLEXPRESS' 
    database = 'TestDB' 
    #username = 'myusername' 
    #password = 'mypassword' 
    #conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';Trusted_Connection=yes;')
    df = pd.read_sql(sqlQuery, conn)
    return df

def getMaxGameDate():
    return getSQLDataInDF('select max(gameDate) as maxDate from nba_game').iloc[0]['maxDate']

maxDate = getMaxGameDate()
getGameData(maxDate)