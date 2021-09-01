

/* Q.1 - What range of years for baseball games played does the provided database cover?*/
SELECT MIN(span_first),MAX(span_last)
FROM homegames;

/* Q.2 - Find the name and height of the shortest player in the database. 
How many games did he play in? What is the name of the team for which he played?*/
SELECT namegiven, height, debut, finalgame, teamid 
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
ORDER BY height
LIMIT 1;

/* Q.3 - Find all players in the database who played at Vanderbilt University. 
Create a list showing each player’s first and last names 
as well as the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors? David Taylor*/
SELECT DISTINCT namegiven, schoolname, SUM(salary), p.playerID, debut, finalgame	
FROM people AS p
INNER JOIN collegeplaying AS c
ON p.playerid = c.playerid
INNER JOIN schools AS s
ON c.schoolid = s.schoolid
INNER JOIN salaries AS pay
ON p.playerid = pay.playerid
WHERE schoolname = 'Vanderbilt University'
GROUP BY namegiven, schoolname, p.playerID
ORDER BY SUM(salary) DESC;

/* Q.4 - INCOMPLETE
Using the fielding table, group players into three groups based on their position:
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/
WITH CTE AS (
SELECT DISTINCT namegiven, 
	COUNT(PO) AS Putouts, yearid, pos,
	CASE 
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = 'OF' THEN 'Outfield'
		ELSE 'Battery'
	END AS positions
FROM people as p
INNER JOIN fielding AS f
ON p.playerid = f.playerid
WHERE pos IN ('OF','SS', '1B', '2B', '3B','P','C')
AND yearid = '2016'
GROUP BY PO, namegiven, yearid, pos
)

SELECT SUM(Putouts) as outfield_group,
	(SELECT SUM(Putouts)
FROM CTE
WHERE positions = 'Infield') as infield_group,
( SELECT SUM(Putouts)
FROM CTE
WHERE positions = 'Battery') as battery_group
FROM CTE
WHERE positions = 'Outfield'

/* Q.5 Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?*/
SELECT franchid, ROUND((AVG(so) + AVG(soa))/2,2) AS avg_so,
		   ROUND(AVG(hra),2) AS avg_hr, yearid, yearid/10*10 AS decade
FROM teams
WHERE yearid between '1920' and '2016'
GROUP BY franchid, yearid, yearid/10*10
ORDER BY yearid;



