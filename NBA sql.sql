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
