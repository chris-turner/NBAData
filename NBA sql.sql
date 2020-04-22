-- update NBA players with multiple teams
update nba_player_team
set newTeamDate = dates.gameDate
from
nba_player_team npt
inner join (select distinct y.playerID, g.gameDate,y.gameID, pbp.PLAYER1_TEAM_ID from
(select playerID, max(u.gameID) as gameID from(
select playerID, count(teamID) as teamID from nba_player_team 
group by playerID
having count(teamID) > 1)x
 inner join (select distinct player1_id,  PLAYER1_TEAM_ID as teamID, min(Game_ID) as gameID
from NBA_game_play_by_play
where PLAYER1_NAME is not null and PLAYER1_TEAM_ID is not null
group by player1_id,  PLAYER1_TEAM_ID) u on x.playerID = u.player1_id
group by playerID) y
inner join nba_game g on y.gameID = g.gameID
inner join NBA_game_play_by_play pbp on y.gameID = pbp.game_Id and y.playerID = pbp.PLAYER1_ID ) dates
on npt.playerID = dates.playerID and dates.PLAYER1_TEAM_ID = npt.teamID


-- NBA Jumpball Stats
select p.playerFullName, w.wins, l.losses, (cast(w.wins as decimal) / (cast(w.wins as decimal) + cast(l.losses as decimal))) as winpct
from nba_player p
inner join 
(select winnerid, count(*) as Wins from nba_jumpball j
where wasopeningtip = 1
group by winnerid) w on w.winnerID = p.playerID
inner join 
(select loserid, count(*) as Losses from nba_jumpball j
where wasopeningtip = 1
group by loserid)l on l.loserid = p.playerID
order by winpct desc

select p.playerFullName, w.wins, l.losses, (cast(w.wins as decimal) / (cast(w.wins as decimal) + cast(l.losses as decimal))) as winpct
from nba_player p
inner join 
(select winnerid, count(*) as Wins from nba_jumpball j
group by winnerid) w on w.winnerID = p.playerID
inner join 
(select loserid, count(*) as Losses from nba_jumpball j
group by loserid)l on l.loserid = p.playerID
order by winpct desc
-- First made FG of the game
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g 
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE = 1
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
  inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate

  -- Last made FG of the game
  select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE = 1
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
  inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate

    -- first FG attempt of game
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate


  -- last FG attempt of game
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate
  
    -- first shot attempt of game including free throws
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2, 3)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate

  -- last shot attempt of game including free throws
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2, 3)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate

  -- first made shot of the game including freethrows
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,3) and (HOMEDESCRIPTION not like 'MISS %' or HOMEDESCRIPTION is null) and (VISITORDESCRIPTION not like 'MISS %' or VISITORDESCRIPTION is null)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate

  -- Last made shot of the game including freethrows
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,3) and (HOMEDESCRIPTION not like 'MISS %' or HOMEDESCRIPTION is null) and (VISITORDESCRIPTION not like 'MISS %' or VISITORDESCRIPTION is null)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
  order by gameDate

-- First made FG of the game
select Scorer, ScoringTeam, count(1) as NumberOfFirstFGMade
from
(select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g 
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE = 1
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
  inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID)x
   group by scorer, ScoringTeam
  order by NumberOfFirstFGMade desc

  -- Last made FG of the game
  select Scorer, ScoringTeam, count(1) as NumberOfLastFGMade
from(
  select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE = 1
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
  inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID
 )x
   group by scorer, ScoringTeam
  order by NumberOfLastFGMade desc

    -- first FG attempt of game
	select Scorer, ScoringTeam, count(1) as NumberOfFirstFGAttempt
from(
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID)x
   group by scorer, ScoringTeam
  order by NumberOfFirstFGAttempt desc


  -- last FG attempt of game
  select Scorer, ScoringTeam, count(1) as NumberOfLastFGAttempt
from(
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID)x
   group by scorer, ScoringTeam
  order by NumberOfLastFGAttempt desc
  
    -- first shot attempt of game including free throws
	 select Scorer, ScoringTeam, count(1) as NumberOfFirstShotAttempt
from(
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2, 3)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID)x
   group by scorer, ScoringTeam
  order by NumberOfFirstShotAttempt desc

  -- last shot attempt of game including free throws
   select Scorer, ScoringTeam, count(1) as NumberOfLastShotAttempt
from(
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,2, 3)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID)x
   group by scorer, ScoringTeam
  order by NumberOfLastShotAttempt desc

  -- first made shot of the game including freethrows
   select Scorer, ScoringTeam, count(1) as NumberOfFirstMadeShot
from(
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, min(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,3) and (HOMEDESCRIPTION not like 'MISS %' or HOMEDESCRIPTION is null) and (VISITORDESCRIPTION not like 'MISS %' or VISITORDESCRIPTION is null)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID)x
   group by scorer, ScoringTeam
  order by NumberOfFirstMadeShot desc

  -- Last made shot of the game including freethrows
  select Scorer, ScoringTeam, count(1) as NumberOfLastMadeShot
from(
select distinct gg.gameDate,ht.TeamFullName as HomeTeam, at.TeamFullName as AwayTeam, g.PLAYER1_NAME as Scorer,
CONCAT(g.PLAYER1_TEAM_CITY, ' ' ,g.PLAYER1_TEAM_NICKNAME) as ScoringTeam,
CASE WHEN g.VISITORDESCRIPTION is null then g.HOMEDESCRIPTION
 WHEN g.HOMEDESCRIPTION is null then g.VISITORDESCRIPTION
END as ScoringDescription
FROM [NBADB].[dbo].[NBA_game_play_by_play] g
inner join 
  (select game_id, max(eventnum) as eventnum FROM [NBADB].[dbo].[NBA_game_play_by_play]
  where EVENTMSGTYPE in (1,3) and (HOMEDESCRIPTION not like 'MISS %' or HOMEDESCRIPTION is null) and (VISITORDESCRIPTION not like 'MISS %' or VISITORDESCRIPTION is null)
  group by game_id)x on g.EVENTNUM = x.eventnum and g.GAME_ID = x.GAME_ID
    inner join NBA_game gg on gg.gameID = x.GAME_ID
  inner join NBA_Team at on gg.awayTeamID = at.TeamID
   inner join NBA_Team ht on gg.homeTeamID = ht.TeamID)x
   group by scorer, ScoringTeam
  order by NumberOfLastMadeShot desc

  

  /*


1�Field Goal Made

2�Field Goal Missed

3�Free Throw Attempt

4�Rebound

5�Turnover

6�Foul

7�Violation

8�Substitution

9�Timeout

10�Jump Ball

11�Ejection

12�Start of Period

13�End of Period


EVENTMSGACTIONTYPE 1 - Jumpshot 2 - Lost ball Turnover 3 - ? 4 - Traveling Turnover / Off Foul 5 - Layup 7 - Dunk 10 - Free throw 1-1 11 - Free throw 1-2 12 - Free throw 2-2 40 - out of bounds 41 - Block/Steal 42 - Driving Layup 50 - Running Dunk 52 - Alley Oop Dunk 55 - Hook Shot 57 - Driving Hook Shot 58 - Turnaround hook shot 66 - Jump Bank Shot 71 - Finger Roll Layup 72 - Putback Layup 108 - Cutting Dunk Shot


  */
