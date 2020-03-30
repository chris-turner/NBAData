select count(*) from NBA_game 

SELECT *
  FROM [TestDB].[dbo].[NBA_player_team]


  select * from nba_player
where playerFullName = 'Steven Adams'
--PlayerId = '1628980'

select * from NBA_Team
where TeamID = '1610612758'

select * from NBA_game_play_by_play
where GAME_ID = '0021900626'
order by EVENTNUM


select * from NBA_game g left join 
(select * from NBA_game_play_by_play
where (HOMEDESCRIPTION like '%jump ball%' or VISITORDESCRIPTION like '%jump ball%')
and PCTIMESTRING = '12:00' and period = 1) s on s.GAME_ID = g.gameID
where s.GAME_ID is null

select * from NBA_game g left join
() j on j.GAME_ID = g.gameID
where j.GAME_ID is null

--
select * from NBA_game_play_by_play
where GAME_ID = '0021900095' order by EVENTNUM 

/*
0021900783  11:57
0021900474
0021900881
0021900095
0021900969
*/

select * from NBA_game_play_by_play
where PLAYER1_ID = 100

insert into nba_jumpball (gameID, eventNum, player1ID, player2ID, winnerID, loserID, wasViolation, wasOpeningTip)
select GAME_ID, EVENTNUM, PLAYER1_ID, PLAYER2_ID,null, null, 0, 0
from NBA_game_play_by_play pbp
inner join NBA_game g on pbp.GAME_ID = g.gameID
where (HOMEDESCRIPTION  like '%Jump Ball%' or VISITORDESCRIPTION  like '%Jump Ball%') 
and PERIOD = 1 and CAST(PCTIMESTRING as time) <= '11:50'  
and (HOMEDESCRIPTION not like '%violation%' or HOMEDESCRIPTION is null) and 
(VISITORDESCRIPTION not like '%violation%'  or VISITORDESCRIPTION is null)
and PLAYER3_NAME is not null and g.gameDate > '1/1/2020'

insert into nba_jumpball (gameID, eventNum, player1ID, player2ID, winnerID, loserID, wasViolation, wasOpeningTip)
select GAME_ID, EVENTNUM, PLAYER1_ID, PLAYER2_ID,null, null, 0, 0
from NBA_game_play_by_play pbp
inner join NBA_game g on pbp.GAME_ID = g.gameID
where (HOMEDESCRIPTION  like '%Jump Ball%' or VISITORDESCRIPTION  like '%Jump Ball%') 
and PERIOD = 1 and CAST(PCTIMESTRING as time) > '11:50'  
and (HOMEDESCRIPTION not like '%violation%' or HOMEDESCRIPTION is null) and 
(VISITORDESCRIPTION not like '%violation%'  or VISITORDESCRIPTION is null)
and PLAYER3_NAME is not null and g.gameDate > '1/1/2020'

insert into nba_jumpball (gameID, eventNum, player1ID, player2ID, winnerID, loserID, wasViolation, wasOpeningTip)
select GAME_ID, EVENTNUM, PLAYER1_ID, PLAYER2_ID,null, null, 0, 0
from NBA_game_play_by_play pbp
inner join NBA_game g on pbp.GAME_ID = g.gameID
where (HOMEDESCRIPTION  like '%Jump Ball%' or VISITORDESCRIPTION  like '%Jump Ball%') 
and PERIOD != 1 
and (HOMEDESCRIPTION not like '%violation%' or HOMEDESCRIPTION is null) and 
(VISITORDESCRIPTION not like '%violation%'  or VISITORDESCRIPTION is null)
and PLAYER3_NAME is not null and g.gameDate > '1/1/2020'



update NBA_jumpball
set winnerID = pbp.player1_id,
loserID = pbp.PLAYER2_ID
from
NBA_jumpball j inner join
NBA_game_play_by_play pbp on j.gameID = pbp.game_Id and j.eventnum = pbp.eventnum
where pbp.player1_team_id = pbp.player3_team_id and loserID is null

update NBA_jumpball
set winnerID = pbp.player2_id,
loserID = pbp.PLAYER1_ID
from
NBA_jumpball j inner join
NBA_game_play_by_play pbp on j.gameID = pbp.game_Id and j.eventnum = pbp.eventnum
where pbp.player2_team_id = pbp.player3_team_id and winnerID is null




select distinct player1_id, player1_name, PLAYER1_TEAM_ID
from NBA_game_play_by_play
where PLAYER1_NAME is not null
union
select distinct player2_id, player2_name, PLAYER2_TEAM_ID
from NBA_game_play_by_play
where PLAYER2_NAME is not null
union
select distinct player3_id, player3_name, PLAYER3_TEAM_ID
from NBA_game_play_by_play
where PLAYER3_NAME is not null

insert into NBA_player ([playerID], playerFullName)

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



select distinct playerID from(
select playerID, count(teamID) as c from nba_player_team 
group by playerID
having count(teamID) > 2)x

UPDATE [NBA_game_play_by_play]
  SET PLAYER1_TEAM_ID = SUBSTRING(PLAYER1_TEAM_ID, 0, (LEN(PLAYER1_TEAM_ID) - 1)),
  PLAYER2_TEAM_ID = SUBSTRING(PLAYER2_TEAM_ID, 0, (LEN(PLAYER2_TEAM_ID) - 1)),
  PLAYER3_TEAM_ID = SUBSTRING(PLAYER3_TEAM_ID, 0, (LEN(PLAYER3_TEAM_ID) - 1))

group by GAME_ID
having count(game_ID) > 1

order by GAME_ID

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



select count(*) from NBA_jumpball
where wasOpeningTip = 1