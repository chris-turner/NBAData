from nba_api.stats.static import players
from nba_api.stats.static import teams
from nba_api.stats.endpoints import leaguegamefinder
from nba_api.stats.endpoints import teamgamelog
from nba_api.stats.endpoints import leaguedashlineups
from nba_api.stats.endpoints import leaguegamelog
from nba_api.stats.library.parameters import Season
from nba_api.stats.library.parameters import SeasonType
from nba_api.stats.endpoints import playbyplayv2
from pandas import DataFrame
import pandas as pd
import pyodbc as pyodbc
import time
        
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
    server = "DESKTOP-HOD0O5L\\SQLEXPRESS"
    database = 'TestDB' 
    #username = 'myusername' 
    #password = 'mypassword' 
    #conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';Trusted_Connection=yes;')
    cursor = conn.cursor()
    cursor.execute(sqlStatement)
    conn.commit()

def getSQLDataInDF(sqlQuery):
    server = "DESKTOP-HOD0O5L\\SQLEXPRESS" 
    database = 'TestDB' 
    #username = 'myusername' 
    #password = 'mypassword' 
    #conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
    conn = pyodbc.connect('DRIVER={SQL Server};SERVER='+server+';DATABASE='+database+';Trusted_Connection=yes;')
    df = pd.read_sql(sqlQuery, conn)
    return df

def getMaxGameDate():
    return getSQLDataInDF('select max(gameDate) as maxDate from nba_game').iloc[0]['maxDate']

def getBoxScoreData():
    gameIDsDf = getSQLDataInDF("select distinct gameID from NBA_game g left  join NBA_game_play_by_play p on p.GAME_ID = g.gameID where p.GAME_ID is null")
    x = 0
    for i, gameIDRow in gameIDsDf.iterrows():
        if x < 15:
            x += 1
            pbpDf = playbyplayv2.PlayByPlayV2(gameIDRow['gameID']).get_data_frames()[0]
            for a, pbpRow in pbpDf.iterrows():
                pbpSql = ("insert into NBA_game_play_by_play (GAME_ID, EVENTNUM, EVENTMSGTYPE, EVENTMSGACTIONTYPE, PERIOD, WCTIMESTRING, PCTIMESTRING, HOMEDESCRIPTION, " + 
                "NEUTRALDESCRIPTION, VISITORDESCRIPTION, SCORE, SCOREMARGIN, PERSON1TYPE, PLAYER1_ID, PLAYER1_NAME, PLAYER1_TEAM_ID, PLAYER1_TEAM_CITY, " + 
                "PLAYER1_TEAM_NICKNAME, PLAYER1_TEAM_ABBREVIATION, PERSON2TYPE, PLAYER2_ID, PLAYER2_NAME, PLAYER2_TEAM_ID, "+
                "PLAYER2_TEAM_CITY, PLAYER2_TEAM_NICKNAME, PLAYER2_TEAM_ABBREVIATION, PERSON3TYPE, PLAYER3_ID, PLAYER3_NAME, PLAYER3_TEAM_ID, PLAYER3_TEAM_CITY," + 
                "PLAYER3_TEAM_NICKNAME, PLAYER3_TEAM_ABBREVIATION, VIDEO_AVAILABLE_FLAG) " +   
                "values(CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END, CASE WHEN '%s' = 'None' OR '%s' = 'nan' THEN NULL ELSE '%s' END);" 
                % (pbpRow["GAME_ID"],pbpRow["GAME_ID"],pbpRow["GAME_ID"],
                pbpRow["EVENTNUM"],pbpRow["EVENTNUM"],pbpRow["EVENTNUM"], 
                pbpRow["EVENTMSGTYPE"],  pbpRow["EVENTMSGTYPE"], pbpRow["EVENTMSGTYPE"],
                pbpRow["EVENTMSGACTIONTYPE"], pbpRow["EVENTMSGACTIONTYPE"],pbpRow["EVENTMSGACTIONTYPE"], 
                pbpRow["PERIOD"], pbpRow["PERIOD"], pbpRow["PERIOD"],
                pbpRow["WCTIMESTRING"], pbpRow["WCTIMESTRING"], pbpRow["WCTIMESTRING"],
                pbpRow["PCTIMESTRING"],pbpRow["PCTIMESTRING"], pbpRow["PCTIMESTRING"],
                str(pbpRow["HOMEDESCRIPTION"]).replace("'","''"), str(pbpRow["HOMEDESCRIPTION"]).replace("'","''"), str(pbpRow["HOMEDESCRIPTION"]).replace("'","''"), 
                str(pbpRow["NEUTRALDESCRIPTION"]).replace("'","''"), str(pbpRow["NEUTRALDESCRIPTION"]).replace("'","''"), str(pbpRow["NEUTRALDESCRIPTION"]).replace("'","''"),
                str(pbpRow["VISITORDESCRIPTION"]).replace("'","''"), str(pbpRow["VISITORDESCRIPTION"]).replace("'","''"), str(pbpRow["VISITORDESCRIPTION"]).replace("'","''"),
                pbpRow["SCORE"],pbpRow["SCORE"],pbpRow["SCORE"], 
                pbpRow["SCOREMARGIN"], pbpRow["SCOREMARGIN"], pbpRow["SCOREMARGIN"], 
                pbpRow["PERSON1TYPE"],pbpRow["PERSON1TYPE"], pbpRow["PERSON1TYPE"],
                pbpRow["PLAYER1_ID"], pbpRow["PLAYER1_ID"],pbpRow["PLAYER1_ID"],  
                str(pbpRow["PLAYER1_NAME"]).replace("'","''"), str(pbpRow["PLAYER1_NAME"]).replace("'","''"), str(pbpRow["PLAYER1_NAME"]).replace("'","''"), 
                pbpRow["PLAYER1_TEAM_ID"], pbpRow["PLAYER1_TEAM_ID"],pbpRow["PLAYER1_TEAM_ID"],  
                pbpRow["PLAYER1_TEAM_CITY"], pbpRow["PLAYER1_TEAM_CITY"],pbpRow["PLAYER1_TEAM_CITY"],
                pbpRow["PLAYER1_TEAM_NICKNAME"], pbpRow["PLAYER1_TEAM_NICKNAME"],pbpRow["PLAYER1_TEAM_NICKNAME"],
                pbpRow["PLAYER1_TEAM_ABBREVIATION"],pbpRow["PLAYER1_TEAM_ABBREVIATION"], pbpRow["PLAYER1_TEAM_ABBREVIATION"], 
                pbpRow["PERSON2TYPE"],pbpRow["PERSON2TYPE"], pbpRow["PERSON2TYPE"],
                pbpRow["PLAYER2_ID"], pbpRow["PLAYER2_ID"], pbpRow["PLAYER2_ID"], 
                str(pbpRow["PLAYER2_NAME"]).replace("'","''"),str(pbpRow["PLAYER2_NAME"]).replace("'","''"), str(pbpRow["PLAYER2_NAME"]).replace("'","''"), 
                pbpRow["PLAYER2_TEAM_ID"], pbpRow["PLAYER2_TEAM_ID"],pbpRow["PLAYER2_TEAM_ID"], 
                pbpRow["PLAYER2_TEAM_CITY"], pbpRow["PLAYER2_TEAM_CITY"], pbpRow["PLAYER2_TEAM_CITY"], 
                pbpRow["PLAYER2_TEAM_NICKNAME"], pbpRow["PLAYER2_TEAM_NICKNAME"],pbpRow["PLAYER2_TEAM_NICKNAME"], 
                pbpRow["PLAYER2_TEAM_ABBREVIATION"], pbpRow["PLAYER2_TEAM_ABBREVIATION"], pbpRow["PLAYER2_TEAM_ABBREVIATION"], 
                pbpRow["PERSON3TYPE"], pbpRow["PERSON3TYPE"],pbpRow["PERSON3TYPE"], 
                pbpRow["PLAYER3_ID"],pbpRow["PLAYER3_ID"], pbpRow["PLAYER3_ID"], 
                str(pbpRow["PLAYER3_NAME"]).replace("'","''"), str(pbpRow["PLAYER3_NAME"]).replace("'","''"),str(pbpRow["PLAYER3_NAME"]).replace("'","''"), 
                pbpRow["PLAYER3_TEAM_ID"],pbpRow["PLAYER3_TEAM_ID"],pbpRow["PLAYER3_TEAM_ID"], 
                pbpRow["PLAYER3_TEAM_CITY"], pbpRow["PLAYER3_TEAM_CITY"],pbpRow["PLAYER3_TEAM_CITY"],  
                pbpRow["PLAYER3_TEAM_NICKNAME"],  pbpRow["PLAYER3_TEAM_NICKNAME"], pbpRow["PLAYER3_TEAM_NICKNAME"],  
                pbpRow["PLAYER3_TEAM_ABBREVIATION"],  pbpRow["PLAYER3_TEAM_ABBREVIATION"], pbpRow["PLAYER3_TEAM_ABBREVIATION"],  
                pbpRow["VIDEO_AVAILABLE_FLAG"], pbpRow["VIDEO_AVAILABLE_FLAG"], pbpRow["VIDEO_AVAILABLE_FLAG"]))
                try:
                    runAndCommitSQL(pbpSql)
                except:
                    print(pbpSql) 
                    #return
                    exit()
            print(str(x) + ": " + gameIDRow['gameID']) 
        else:
            x=0
            print("wait 10 mins to avoid timeout")
            time.sleep(600) #wait 10 mins to avoid timeout

def loadLatestGamesAndBoxScores():
    maxDate = getMaxGameDate()
    getGameData(maxDate)
    getBoxScoreData()
    runAndCommitSQL("UPDATE [NBA_game_play_by_play] SET PLAYER1_TEAM_ID = SUBSTRING(PLAYER1_TEAM_ID, 0, (LEN(PLAYER1_TEAM_ID) - 1)), PLAYER2_TEAM_ID = SUBSTRING(PLAYER2_TEAM_ID, 0, (LEN(PLAYER2_TEAM_ID) - 1)),PLAYER3_TEAM_ID = SUBSTRING(PLAYER3_TEAM_ID, 0, (LEN(PLAYER3_TEAM_ID) - 1))")
    loadJumpballData(maxDate)

def loadJumpballData(maxDate):
    jbSql = "insert into nba_jumpball (gameID, eventNum, player1ID, player2ID, winnerID, loserID, wasViolation, wasOpeningTip)"+
    "select GAME_ID, EVENTNUM, PLAYER1_ID, PLAYER2_ID,null, null, 0, 0"+
    "from NBA_game_play_by_play pbp "+
    "inner join NBA_game g on pbp.GAME_ID = g.gameID"+
    "where (HOMEDESCRIPTION  like '%Jump Ball%' or VISITORDESCRIPTION  like '%Jump Ball%') "+
    "and PERIOD = 1 and CAST(PCTIMESTRING as time) <= '11:50'  "+
    "and (HOMEDESCRIPTION not like '%violation%' or HOMEDESCRIPTION is null) and "+
    "(VISITORDESCRIPTION not like '%violation%'  or VISITORDESCRIPTION is null) "+
    "and PLAYER3_NAME is not null and g.gameDate > '" + maxDate + "';"+
    "insert into nba_jumpball (gameID, eventNum, player1ID, player2ID, winnerID, loserID, wasViolation, wasOpeningTip) "+
    "select GAME_ID, EVENTNUM, PLAYER1_ID, PLAYER2_ID,null, null, 0, 0 "+
    "from NBA_game_play_by_play pbp"+
    "inner join NBA_game g on pbp.GAME_ID = g.gameID "+
    "where (HOMEDESCRIPTION  like '%Jump Ball%' or VISITORDESCRIPTION  like '%Jump Ball%') "+
    "and PERIOD = 1 and CAST(PCTIMESTRING as time) > '11:50'  "+
    "and (HOMEDESCRIPTION not like '%violation%' or HOMEDESCRIPTION is null) and "+
    "(VISITORDESCRIPTION not like '%violation%'  or VISITORDESCRIPTION is null) "+
    "and PLAYER3_NAME is not null and g.gameDate > '" + maxDate + "'; "+
    "insert into nba_jumpball (gameID, eventNum, player1ID, player2ID, winnerID, loserID, wasViolation, wasOpeningTip) "+
    "select GAME_ID, EVENTNUM, PLAYER1_ID, PLAYER2_ID,null, null, 0, 0 "+
    "from NBA_game_play_by_play pbp "+
    "inner join NBA_game g on pbp.GAME_ID = g.gameID "+
    "where (HOMEDESCRIPTION  like '%Jump Ball%' or VISITORDESCRIPTION  like '%Jump Ball%') "+
    "and PERIOD != 1 "+
    "and (HOMEDESCRIPTION not like '%violation%' or HOMEDESCRIPTION is null) and "+
    "(VISITORDESCRIPTION not like '%violation%'  or VISITORDESCRIPTION is null) "+
    "and PLAYER3_NAME is not null and g.gameDate > '" + maxDate + "';
    runAndCommitSQL(jbSql)
    winlossSQL = "update NBA_jumpball "+
    "set winnerID = pbp.player1_id, "+
    "loserID = pbp.PLAYER2_ID "+
    "from "+
    "NBA_jumpball j inner join "+
    "NBA_game_play_by_play pbp on j.gameID = pbp.game_Id and j.eventnum = pbp.eventnum "+
    "where pbp.player1_team_id = pbp.player3_team_id and loserID is null; "+
    "update NBA_jumpball "+
    "set winnerID = pbp.player2_id, "+
    "loserID = pbp.PLAYER1_ID "+
    "from "+
    "NBA_jumpball j inner join "+
    "NBA_game_play_by_play pbp on j.gameID = pbp.game_Id and j.eventnum = pbp.eventnum "+
    "where pbp.player2_team_id = pbp.player3_team_id and winnerID is null; "
    runAndCommitSQL(winlossSQL)

loadLatestGamesAndBoxScores()
        
    

