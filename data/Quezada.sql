

/* Q.1 - What range of years for baseball games played does the provided database cover?*/
SELECT MIN(span_first),MAX(span_last)
FROM homegames;

/* Q.2 - Find the name and height of the shortest player in the database. 
How many games did he play in? What is the name of the team for which he played?*/
SELECT namegiven, height, debut, finalgame, teamid, SUM(a.g_all) as games_played
FROM people AS p
INNER JOIN appearances AS a
USING (playerid)
GROUP BY namegiven, height, debut, finalgame, teamid
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

/* Q.4 - 
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

/* Q.5 
Find the average number of strikeouts per game by decade since 1920. 
Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends?*/
WITH CTE AS (
	SELECT franchid, ROUND((AVG(so) + AVG(soa))/2,2) AS avg_so, g, 
		   ROUND(AVG(hra),2) AS avg_hr, yearid, yearid/10*10 AS decade
FROM teams
WHERE yearid between '1920' and '2016'
GROUP BY franchid, yearid, yearid/10*10, g
ORDER BY yearid)

SELECT franchid, 
		ROUND(SUM(avg_so)/g,2) as so_pg, 
		ROUND(SUM(avg_hr)/g,2) as hr_pg, 
		yearid, decade,g
FROM CTE
GROUP BY franchid, g, avg_hr, yearid, decade
ORDER BY yearid;

/* Q.6 Find the player who had the most success stealing bases in 2016, 
where success is measured as the percentage of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted at least 20 stolen bases.*/

SELECT namegiven, sb, cs, (sb + cs)	AS total_stln,
	ROUND(CAST(sb AS numeric)/(CAST(sb+cs as numeric)),2) *100 AS perc_stl
FROM people as p
INNER JOIN batting AS b
ON p.playerid = b.playerid
WHERE b.yearid = '2016' 
	AND sb >= 20
ORDER BY perc_stl DESC;

/* Q.7 
From 1970 – 2016, 
What is the smallest number of wins for a team that did win the world series? 
*/
WITH CTE AS (SELECT teamid, g, w, DivWin, WSWin, yearid
FROM teams
WHERE yearid between '1970' and '2016'
ORDER BY yearid)


SELECT teamid, MIN(w), WSWin, yearid
FROM CTE
WHERE WSWin = 'Y' AND yearid <> '1981'
GROUP BY teamid, WSWin, yearid
ORDER BY MIN(w);
/*
what is the largest number of wins for a team that did not win the world series?*/
WITH CTE AS (SELECT teamid, g, w, DivWin, WSWin, yearid
FROM teams
WHERE yearid between '1970' and '2016'
ORDER BY yearid)

SELECT teamid, MAX(w), WSWin, yearid
FROM CTE
WHERE WSWin = 'N'
GROUP BY teamid, WSWin, yearid
ORDER BY MAX(w) DESC;
/*
Doing this will probably result in an unusually small number of wins for a world series champion – 
determine why this is the case. 
Then redo your query, excluding the problem year. 
How often from 1970 – 2016 was it the case that a team with the most wins also won the world series?
What percentage of the time?*/

