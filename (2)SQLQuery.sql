-- Create a database
CREATE DATABASE European_Soccer
go
-- Review the data in the tables
SELECT * FROM [dbo].[Country]
SELECT * FROM [dbo].[League]
SELECT * FROM [dbo].[Match]

SELECT * FROM [dbo].[Player]
SELECT * FROM [dbo].[Player_Attributes]

SELECT * FROM [dbo].[Team]
SELECT * FROM [dbo].[Team_Attributes]
-- Clean the data
-- Remove unnecessary columns from the Match table
ALTER TABLE [dbo].[Match] 
DROP COLUMN 
    home_player_X1, home_player_X2, home_player_X3, home_player_X4, home_player_X5,
    home_player_X6, home_player_X7, home_player_X8, home_player_X9, home_player_X10,
    home_player_X11, away_player_X1, away_player_X2, away_player_X3, away_player_X4,
    away_player_X5, away_player_X6, away_player_X7, away_player_X8, away_player_X9,
    away_player_X10, away_player_X11, home_player_Y1, home_player_Y2, home_player_Y3,
    home_player_Y4, home_player_Y5, home_player_Y6, home_player_Y7, home_player_Y8,
    home_player_Y9, home_player_Y10, home_player_Y11, away_player_Y1, away_player_Y2,
    away_player_Y3, away_player_Y4, away_player_Y5, away_player_Y6, away_player_Y7,
    away_player_Y8, away_player_Y9, away_player_Y10, away_player_Y11, 
    B365H, B365D, B365A, BWH, BWD, BWA, 
    IWH, IWD, IWA, LBH, LBD, LBA, 
    PSH, PSD, PSA, WHH, WHD, WHA, 
    SJH, SJD, SJA, VCH, VCD, VCA, 
    GBH, GBD, GBA, BSH, BSD, BSA;

ALTER TABLE [dbo].[Match]
DROP COLUMN 
    home_player_1, home_player_2, home_player_3, home_player_4, home_player_5,
    home_player_6, home_player_7, home_player_8, home_player_9, home_player_10, home_player_11,
    away_player_1, away_player_2, away_player_3, away_player_4, away_player_5,
    away_player_6, away_player_7, away_player_8, away_player_9, away_player_10, away_player_11,
    goal, shoton, shotoff, foulcommit, [card], [cross], corner, possession;

-- Join the Country and League tables
SELECT c.[name] AS Country, l.[name] AS League
FROM [dbo].[Country] c JOIN [dbo].[League] l ON c.id=l.country_id
-- Left Join Country, League and Match tables
SELECT DISTINCT c.[name] AS Country, l.[name] AS League, m.season, m.stage,FORMAT(m.[date], 'yyyy-MM-dd') as [date],
       m.match_api_id, m.home_team_api_id, m.away_team_api_id, m.home_team_goal, m.away_team_goal 
FROM [dbo].[Match] m LEFT JOIN [dbo].[Country] c ON m.country_id=c.id LEFT JOIN [dbo].[League] l ON m.league_id=l.id
-- Right Join Player and Player_Attributes tables
SELECT
    p.player_api_id,
    p.player_name,
    p.player_fifa_api_id,
    FORMAT(p.birthday, 'yyyy-MM-dd') as [date],
    p.height,
    p.[weight],
	FORMAT(pa.[date], 'yyyy-MM-dd') as [date],
    ISNULL(pa.overall_rating, 0) AS overall_rating,
    ISNULL(pa.potential, 0) AS potential,
    -- Replace NULL values in preferred_foot with 'right'
    CASE 
        WHEN pa.preferred_foot IS NULL THEN 'right'
        ELSE pa.preferred_foot
    END AS preferred_foot,
    -- Replace NULL or invalid values in attacking_work_rate and defensive_work_rate
    CASE 
        WHEN pa.attacking_work_rate IS NULL OR pa.attacking_work_rate NOT IN ('low', 'medium', 'high') THEN 'low'
        ELSE pa.attacking_work_rate
    END AS attacking_work_rate,
    CASE 
        WHEN pa.defensive_work_rate IS NULL OR pa.defensive_work_rate NOT IN ('low', 'medium', 'high') THEN 'low'
        ELSE pa.defensive_work_rate
    END AS defensive_work_rate,
    ISNULL(pa.crossing, 0) AS crossing,
    ISNULL(pa.finishing, 0) AS finishing,
    ISNULL(pa.heading_accuracy, 0) AS heading_accuracy,
    ISNULL(pa.short_passing, 0) AS short_passing,
    ISNULL(pa.dribbling, 0) AS dribbling,
    ISNULL(pa.ball_control, 0) AS ball_control,
    ISNULL(pa.acceleration, 0) AS acceleration,
    ISNULL(pa.sprint_speed, 0) AS sprint_speed,
    ISNULL(pa.agility, 0) AS agility,
    ISNULL(pa.shot_power, 0) AS shot_power,
    ISNULL(pa.jumping, 0) AS jumping,
    ISNULL(pa.stamina, 0) AS stamina,
    ISNULL(pa.strength, 0) AS strength
FROM 
    Player p
JOIN 
    Player_Attributes pa ON p.player_api_id = pa.player_api_id
WHERE 
    pa.date = (SELECT MAX(date) FROM Player_Attributes WHERE player_api_id = p.player_api_id)
ORDER BY 
    pa.overall_rating DESC;
-- Join Team and Team_Attributes tables
SELECT 
	t.team_api_id,
	t.team_fifa_api_id,
    t.team_long_name,
    t.team_short_name,
	FORMAT(ta.[date], 'yyyy-MM-dd') as [date],
    ISNULL(ta.buildUpPlaySpeed, 0) AS buildUpPlaySpeed,
    ISNULL(ta.buildUpPlayDribbling, 0) AS buildUpPlayDribbling,
    ISNULL(ta.buildUpPlayPassing, 0) AS buildUpPlayPassing,
    ISNULL(ta.chanceCreationPassing, 0) AS chanceCreationPassing,
    ISNULL(ta.chanceCreationCrossing, 0) AS chanceCreationCrossing,
    ISNULL(ta.chanceCreationShooting, 0) AS chanceCreationShooting,
    ISNULL(ta.defencePressure, 0) AS defencePressure,
    ISNULL(ta.defenceAggression, 0) AS defenceAggression,
    ISNULL(ta.defenceTeamWidth, 0) AS defenceTeamWidth
FROM 
    Team t
JOIN 
    Team_Attributes ta ON t.team_api_id = ta.team_api_id
ORDER BY 
    t.team_long_name;

