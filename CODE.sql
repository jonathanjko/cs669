-- Drop tables
DROP TABLE RegularSeasonGame;
DROP TABLE PlayoffGame;
DROP TABLE ExhibitionGame;
DROP TABLE RookieContract;
DROP TABLE VeteranContract;
DROP TABLE MaxContract;
DROP TABLE FreeAgentContract;
DROP TABLE MinorInjury;
DROP TABLE MajorInjury;
DROP TABLE PlayerStats;
DROP TABLE TeamStats;
DROP TABLE Contract;
DROP TABLE pRecovery;
DROP TABLE Injury;
DROP TABLE SalaryCap;
DROP TABLE TeamSeason;
DROP TABLE Season;
DROP TABLE Game;
DROP TABLE Player;
DROP TABLE Team;

-- Drop sequences
DROP SEQUENCE player_seq;
DROP SEQUENCE team_seq;
DROP SEQUENCE contract_seq;
DROP SEQUENCE season_seq;
DROP SEQUENCE salarycap_seq;
DROP SEQUENCE game_seq;
DROP SEQUENCE injury_seq;
DROP SEQUENCE recovery_seq;

-- Create sequences for tables
CREATE SEQUENCE player_seq START 1;
CREATE SEQUENCE team_seq START 1;
CREATE SEQUENCE contract_seq START 1;
CREATE SEQUENCE season_seq START 1;
CREATE SEQUENCE salarycap_seq START 1;
CREATE SEQUENCE game_seq START 1;
CREATE SEQUENCE injury_seq START 1;
CREATE SEQUENCE recovery_seq START 1;

-- Create Team Table OLD
-- CREATE TABLE Team (
--    teamID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('team_seq'),
--    teamName VARCHAR(100) NOT NULL,
--    conference VARCHAR(50) NOT NULL,
--    division VARCHAR(50) NOT NULL,
-- );

-- Create Conference Table
CREATE TABLE Conference (
    conferenceID INT NOT NULL PRIMARY KEY,
    conferenceName VARCHAR(100) NOT NULL
);

-- Insert Conferences
INSERT INTO Conference (conferenceID, conferenceName)
VALUES 
    (1, 'Western'),
    (2, 'Eastern');

-- Create Division Table
CREATE TABLE Division (
    divisionID INT NOT NULL PRIMARY KEY,
    divisionName VARCHAR(100) NOT NULL,
    conferenceID INT NOT NULL REFERENCES Conference(conferenceID)
);

-- Insert Divisions
INSERT INTO Division (divisionID, divisionName, conferenceID)
VALUES 
    (1, 'Pacific', 1),        -- Western Conference
    (2, 'Northwest', 1),      -- Western Conference
    (3, 'Southwest', 1),      -- Western Conference
    (4, 'Atlantic', 2),       -- Eastern Conference
    (5, 'Central', 2),        -- Eastern Conference
    (6, 'Southeast', 2);      -- Eastern Conference


-- Updated Team Table
CREATE TABLE Team (
    teamID INT NOT NULL PRIMARY KEY,
    teamName VARCHAR(100) NOT NULL,
    conferenceID INT NOT NULL REFERENCES Conference(conferenceID),
    divisionID INT NOT NULL REFERENCES Division(divisionID)
);


-- Create Player Table
CREATE TABLE Player (
    playerID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('player_seq'),
    playerName VARCHAR(100) NOT NULL,
    teamID INT REFERENCES Team(teamID),
    playerPosition VARCHAR(50) NOT NULL
);

-- Create Guard Table
-- CREATE TABLE Guard (
--     playerID INT PRIMARY KEY REFERENCES Player(playerID)
-- );

-- Create Forward Table
-- CREATE TABLE spForward (
--     playerID INT PRIMARY KEY REFERENCES Player(playerID)
-- );

-- Create Center Table
-- CREATE TABLE Center (
--     playerID INT PRIMARY KEY REFERENCES Player(playerID)
-- );

-- Create Contract Table
CREATE TABLE Contract (
    contractID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('contract_seq'),
    playerID INT REFERENCES Player(playerID),
    teamID INT REFERENCES Team(teamID),
    contractStart DATE NOT NULL,
    contractEnd DATE NOT NULL,
    annualSalary NUMERIC NOT NULL
);

-- Create RookieContract Table
CREATE TABLE RookieContract (
    contractID INT PRIMARY KEY REFERENCES Contract(contractID),
    rookieScale NUMERIC NOT NULL
);

-- Create VeteranContract Table
CREATE TABLE VeteranContract (
    contractID INT PRIMARY KEY REFERENCES Contract(contractID),
    veteranBonus NUMERIC NOT NULL
);

-- Create MaxContract Table
CREATE TABLE MaxContract (
    contractID INT PRIMARY KEY REFERENCES Contract(contractID),
    maxAmount NUMERIC NOT NULL
);

-- Create FreeAgentContract Table
CREATE TABLE FreeAgentContract (
    contractID INT PRIMARY KEY REFERENCES Contract(contractID),
    freeAgentBonus NUMERIC NOT NULL
);

-- Create Season Table
CREATE TABLE Season (
    seasonID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('season_seq'),
    seasonYear INT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL
);

-- Create SalaryCap Table
CREATE TABLE SalaryCap (
    capID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('salarycap_seq'),
    seasonID INT REFERENCES Season(seasonID),
    salaryCap NUMERIC NOT NULL,
    firstApron NUMERIC NOT NULL,
    secondApron NUMERIC NOT NULL
);

-- Create Game Table
CREATE TABLE Game (
    gameID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('game_seq'),
    game_date DATE NOT NULL,
    hometeamID INT REFERENCES Team(teamID),
    awayteamID INT REFERENCES Team(teamID),
    home_score INT NOT NULL,
    away_score INT NOT NULL
);

-- Create RegularSeasonGame Table
CREATE TABLE RegularSeasonGame (
    gameID INT PRIMARY KEY REFERENCES Game(gameID)
);

-- Create PlayoffGame Table
CREATE TABLE PlayoffGame (
    gameID INT PRIMARY KEY REFERENCES Game(gameID)
);

-- Create ExhibitionGame Table
CREATE TABLE ExhibitionGame (
    gameID INT PRIMARY KEY REFERENCES Game(gameID)
);

-- Create PlayerStats Table
CREATE TABLE PlayerStats (
    playerID INT REFERENCES Player(playerID),
    gameID INT REFERENCES Game(gameID),
    points INT NOT NULL,
    rebounds INT NOT NULL,
    assists INT NOT NULL,
    steals INT NOT NULL,
    blocks INT NOT NULL,
    turnovers INT NOT NULL,
    ft_percent NUMERIC NOT NULL,
    fg_percent NUMERIC NOT NULL,
    three_points INT NOT NULL,
    PRIMARY KEY (playerID, gameID)
);

-- Create TeamStats Table
CREATE TABLE TeamStats (
    teamID INT REFERENCES Team(teamID),
    gameID INT REFERENCES Game(gameID),
    points INT NOT NULL,
    rebounds INT NOT NULL,
    assists INT NOT NULL,
    steals INT NOT NULL,
    blocks INT NOT NULL,
    turnovers INT NOT NULL,
    ft_percent NUMERIC NOT NULL,
    fg_percent NUMERIC NOT NULL,
    three_points INT NOT NULL,
    PRIMARY KEY (teamID, gameID)
);

-- Create Injury Table
CREATE TABLE Injury (
    injuryID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('injury_seq'),
    playerID INT REFERENCES Player(playerID),
    gameID INT REFERENCES Game(gameID),
    injuryType VARCHAR(100) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE,
    status VARCHAR(50) NOT NULL,
    recoveryTime INT
);

-- Create MinorInjury Table
CREATE TABLE MinorInjury (
    injuryID INT PRIMARY KEY REFERENCES Injury(injuryID),
    minorSeverity VARCHAR(100)
);

-- Create MajorInjury Table
CREATE TABLE MajorInjury (
    injuryID INT PRIMARY KEY REFERENCES Injury(injuryID),
    majorSeverity VARCHAR(100)
);

-- Create Recovery Table
CREATE TABLE pRecovery (
    recoveryID INT NOT NULL PRIMARY KEY DEFAULT NEXTVAL('recovery_seq'),
    injuryID INT REFERENCES Injury(injuryID),
    startDate DATE NOT NULL,
    endDate DATE,
    status VARCHAR(50) NOT NULL
);

-- Create TeamSeason Table (Junction Table)
CREATE TABLE TeamSeason (
    teamID INT REFERENCES Team(teamID),
    seasonID INT REFERENCES Season(seasonID),
    PRIMARY KEY (teamID, seasonID)
);


-- Stored Procedure Execution
-- Add New Player
CREATE OR REPLACE PROCEDURE AddPlayer(
    p_playerID IN INT,
    p_playerName IN VARCHAR,
    p_teamID IN INT,
    p_playerPosition IN VARCHAR
)
AS
$$
BEGIN
	-- Check if the teamID exists in the Team table
    IF NOT EXISTS (SELECT 1 FROM Team WHERE teamID = p_teamID) THEN
        RAISE EXCEPTION 'Invalid teamID %', p_teamID;
    END IF;

	-- If the teamID is valid, insert the player
    INSERT INTO Player(playerID, playerName, teamID, playerPosition)
    VALUES (p_playerID, p_playerName, p_teamID, p_playerPosition);
END;
$$ LANGUAGE plpgsql;

-- Execute the stored procedure 
START TRANSACTION;
DO
$$
BEGIN
    CALL AddPlayer(1, 'LeBron James', 1, 'spForward');
END$$;
COMMIT;

-- Verify the insert with a SELECT query
SELECT * FROM Player WHERE playerID = 1;
-- Add New Team
CREATE OR REPLACE PROCEDURE AddTeam(
    p_teamID IN INT,         
    p_teamName IN VARCHAR,   
    p_conferenceName IN VARCHAR, 
    p_divisionName IN VARCHAR    
)
AS
$$
DECLARE
    v_conferenceID INT;
    v_divisionID INT;
BEGIN
    -- Retrieve conferenceID based on the conferenceName
    SELECT conferenceID INTO v_conferenceID
    FROM Conference
    WHERE conferenceName = p_conferenceName;

    IF v_conferenceID IS NULL THEN
        RAISE EXCEPTION 'Conference % does not exist', p_conferenceName;
    END IF;

    -- Retrieve divisionID based on the divisionName and conferenceID
    SELECT divisionID INTO v_divisionID
    FROM Division
    WHERE divisionName = p_divisionName
      AND conferenceID = v_conferenceID;

    IF v_divisionID IS NULL THEN
        RAISE EXCEPTION 'Division % does not exist in Conference %', p_divisionName, p_conferenceName;
    END IF;

    -- Check if teamID already exists
    IF EXISTS (SELECT 1 FROM Team WHERE teamID = p_teamID) THEN
        RAISE EXCEPTION 'Team with ID % already exists', p_teamID;
    END IF;

    -- Insert the new team
    INSERT INTO Team(teamID, teamName, conferenceID, divisionID)
    VALUES (p_teamID, p_teamName, v_conferenceID, v_divisionID);
END;
$$ LANGUAGE plpgsql;

START TRANSACTION;
DO
$$
BEGIN
	-- Add a new team
    CALL AddTeam(1, 'Los Angeles Lakers', 'Western', 'Pacific');
END$$;

-- Verify the insert with a SELECT query
SELECT * FROM Team WHERE teamID = 1;

--START TRANSACTION;
--DO
--$$
--BEGIN
	-- Attempt to add a team with the same teamID to trigger the exception
--    CALL AddTeam(1, 'Golden State Warriors', 'Western', 'Pacific');
--END$$;

-- Add New Game
-- Insert teamID = 2
INSERT INTO Team (teamID, teamName, conferenceID, divisionID)
VALUES 
    (2, 'Golden State Warriors', 1, 1);
COMMIT;

CREATE OR REPLACE PROCEDURE AddGame(
    p_gameID IN INT,
    p_game_date IN DATE,
    p_hometeamID IN INT,
    p_awayteamID IN INT,
    p_home_score IN INT,
    p_away_score IN INT
)
AS
$$
BEGIN
    -- Start a new transaction block
    BEGIN
        -- Check if home and away teams exist
        IF NOT EXISTS (SELECT 1 FROM Team WHERE teamID = p_hometeamID) THEN
            RAISE EXCEPTION 'Home team with ID % does not exist', p_hometeamID;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM Team WHERE teamID = p_awayteamID) THEN
            RAISE EXCEPTION 'Away team with ID % does not exist', p_awayteamID;
        END IF;

        -- Check if gameID already exists
        IF EXISTS (SELECT 1 FROM Game WHERE gameID = p_gameID) THEN
            RAISE EXCEPTION 'Game with ID % already exists', p_gameID;
        END IF;

        -- Insert the new game
        INSERT INTO Game(gameID, game_date, hometeamID, awayteamID, home_score, away_score)
        VALUES (p_gameID, p_game_date, p_hometeamID, p_awayteamID, p_home_score, p_away_score);
    EXCEPTION
        WHEN OTHERS THEN
            -- Raise notice but don't attempt to manually rollback; PostgreSQL will handle it.
            RAISE NOTICE 'Transaction failed: %', SQLERRM;
            RAISE;
    END;
END;
$$ LANGUAGE plpgsql;

-- Example
START TRANSACTION;
DO
$$
BEGIN
    -- Attempt to add a new game
    CALL AddGame(1, '2023-01-01', 1, 2, 102, 99);
END$$;

-- Select the inserted game to verify
SELECT * FROM Game WHERE gameID = 1;

-- Example Execution: Attempting to add a game with an invalid home team ID
-- START TRANSACTION;
-- DO
-- $$
-- BEGIN
    -- Attempt to add a game with an invalid home team ID (e.g., teamID 99 does not exist)
--    CALL AddGame(2, '2023-01-05', 99, 2, 105, 98);
--END$$;
--COMMIT;

-- A More Complex Query Joining Multiple Tables
SELECT P.playerName, G.game_date, PS.points
FROM PlayerStats PS
JOIN Player P ON PS.playerID = P.playerID
JOIN Game G ON PS.gameID = G.gameID
WHERE G.game_date = '2023-01-01';

-- Add New Contract
CREATE OR REPLACE PROCEDURE AddContract(
    p_contractID IN INT,
    p_playerID IN INT,
    p_teamID IN INT,
    p_contractStart IN DATE,
    p_contractEnd IN DATE,
    p_annualSalary IN NUMERIC
)
AS
$$
BEGIN
    -- Check if contractID already exists
    IF EXISTS (SELECT 1 FROM Contract WHERE contractID = p_contractID) THEN
        RAISE EXCEPTION 'Contract with ID % already exists', p_contractID;
    END IF;
    -- Check if playerID exists
    IF NOT EXISTS (SELECT 1 FROM Player WHERE playerID = p_playerID) THEN
        RAISE EXCEPTION 'Player with ID % does not exist', p_playerID;
    END IF;    
    -- Check if teamID exists
    IF NOT EXISTS (SELECT 1 FROM Team WHERE teamID = p_teamID) THEN
        RAISE EXCEPTION 'Team with ID % does not exist', p_teamID;
    END IF;
    -- Insert the new contract
    INSERT INTO Contract(contractID, playerID, teamID, contractStart, contractEnd, annualSalary)
    VALUES (p_contractID, p_playerID, p_teamID, p_contractStart, p_contractEnd, p_annualSalary);
END;
$$ LANGUAGE plpgsql;

-- Add a new contract
START TRANSACTION;
DO
$$
BEGIN
    CALL AddContract(1, 1, 1, '2023-07-01', '2026-06-30', 35000000);
END$$;
COMMIT;

-- View
SELECT * FROM Contract WHERE contractID = 1;

-- Attempt to add a contract with the same contractID to trigger the exception
-- START TRANSACTION;
-- DO
-- $$
-- BEGIN
--     CALL AddContract(1, 1, 1, '2023-07-01', '2026-06-30', 35000000);
-- END$$;
-- COMMIT;

-- Sample Data
-- Insert a Season
INSERT INTO Season (seasonID, seasonYear, startDate, endDate)
VALUES (1, 2023, '2023-01-01', '2023-12-31');

-- Insert Players
INSERT INTO Player (playerID, playerName, teamID, playerPosition)
VALUES 
    (1, 'LeBron James', 1, 'Forward'),
    (2, 'Stephen Curry', 2, 'Guard');

-- Insert Games
INSERT INTO Game (gameID, game_date, hometeamID, awayteamID, home_score, away_score)
VALUES 
    (1, '2023-01-01', 1, 2, 102, 99),
    (2, '2023-01-05', 2, 1, 110, 105);

-- Insert PlayerStats
INSERT INTO PlayerStats (playerID, gameID, points, rebounds, assists, steals, blocks, turnovers, ft_percent, fg_percent, three_points)
VALUES 
    (1, 1, 30, 10, 8, 2, 1, 3, 85.0, 50.0, 4),
    (2, 1, 25, 5, 10, 3, 0, 2, 90.0, 55.0, 5),
    (1, 2, 28, 9, 7, 1, 2, 1, 87.0, 52.0, 3),
    (2, 2, 35, 4, 9, 2, 1, 1, 93.0, 57.0, 6);

-- Questions and Queries
-- AVG PTS by Player?
SELECT P.playerID, P.playerName, AVG(PS.points) AS avg_points
FROM PlayerStats PS
JOIN Player P ON PS.playerID = P.playerID
JOIN Game G ON PS.gameID = G.gameID
JOIN Season S ON G.game_date BETWEEN S.startDate AND S.endDate
WHERE S.seasonYear = 2023
GROUP BY P.playerID, P.playerName
HAVING AVG(PS.points) > 15; -- Filter for players with an average of more than 15 points per game

-- Example ViewCreation
CREATE VIEW PlayerAveragePoints AS
SELECT playerName, AVG(points) AS avg_points
FROM PlayerStats PS
JOIN Player P ON PS.playerID = P.playerID
JOIN Game G ON PS.gameID = G.gameID
JOIN Season S ON G.game_date BETWEEN S.startDate AND S.endDate
WHERE S.seasonYear = 2023
GROUP BY playerName
HAVING AVG(points) > 15;

-- Select from the view
SELECT * FROM PlayerAveragePoints;

-- Sample Data
-- Insert team stats into the TeamStats table for the existing games
INSERT INTO TeamStats (teamID, gameID, points, rebounds, assists, steals, blocks, turnovers, ft_percent, fg_percent, three_points)
VALUES 
    -- Stats for team 1 in game 1 and game 2
    (1, 1, 102, 45, 20, 5, 3, 12, 78.9, 45.2, 10),
    (1, 2, 105, 48, 22, 4, 2, 10, 80.0, 47.1, 11),

    -- Stats for team 2 in game 1 and game 2
    (2, 1, 99, 50, 18, 7, 5, 11, 80.3, 46.2, 9),
    (2, 2, 110, 52, 19, 8, 6, 9, 81.0, 48.0, 12);

-- Verify the data insertion with a SELECT query
SELECT * FROM TeamStats;
-- AVG PTS per Game by Team?
SELECT teamID, AVG(points) AS avg_points
FROM TeamStats
GROUP BY teamID
ORDER BY avg_points DESC
LIMIT 1;

-- View for Average Points per Game by Team
CREATE VIEW AvgPointsPerGameByTeam AS
SELECT teamID, AVG(points) AS avg_points
FROM TeamStats
GROUP BY teamID
ORDER BY avg_points DESC;

SELECT * FROM AvgPointsPerGameByTeam;

-- Sample Data
-- Insert injuries for playerID = 1 
INSERT INTO Injury (injuryID, playerID, gameID, injuryType, startDate, endDate, status, recoveryTime)
VALUES 
    (1, 1, 1, 'Hamstring Strain', '2023-01-02', '2023-01-15', 'Recovered', 14),
    (2, 1, 2, 'Ankle Sprain', '2023-02-05', '2023-02-20', 'Recovered', 15),
    (3, 1, 1, 'Shoulder Dislocation', '2023-03-10', NULL, 'Ongoing', 0);  -- Use 0 as a placeholder for ongoing injury

-- Verify the data insertion with a SELECT query
SELECT * FROM Injury WHERE playerID = 1;

-- All injuries for player
SELECT injuryID, injuryType, startDate, endDate, status
FROM Injury
WHERE playerID = 1;

-- View for All Injuries for a Specific Player
CREATE VIEW PlayerInjuries AS
SELECT injuryID, injuryType, startDate, endDate, status
FROM Injury
WHERE playerID = 1;

SELECT * FROM PlayerInjuries;


INSERT INTO Game (gameID, game_date, hometeamID, awayteamID, home_score, away_score)
VALUES 
	(3, '2023-01-10', 1, 2, 98, 101);
INSERT INTO TeamStats (teamID, gameID, points, rebounds, assists, steals, blocks, turnovers, ft_percent, fg_percent, three_points)
VALUES 
	-- Game 3 stats
    (1, 3, 98, 48, 22, 9, 7, 11, 79.0, 47.0, 10),
    (2, 3, 101, 44, 21, 8, 5, 12, 77.0, 46.0, 8);

-- Total rebounds for each team in a season?
SELECT T.teamName, SUM(TS.rebounds) AS total_rebounds
FROM TeamStats TS
JOIN Team T ON TS.teamID = T.teamID
JOIN Game G ON TS.gameID = G.gameID
JOIN Season S ON G.game_date BETWEEN S.startDate AND S.endDate
WHERE S.seasonYear = 2023
GROUP BY T.teamName;

-- View for Total Rebounds by Each Team in a Season
CREATE VIEW TotalReboundsByTeamInSeason AS
SELECT T.teamName, SUM(TS.rebounds) AS total_rebounds
FROM TeamStats TS
JOIN Team T ON TS.teamID = T.teamID
JOIN Game G ON TS.gameID = G.gameID
JOIN Season S ON G.game_date BETWEEN S.startDate AND S.endDate
WHERE S.seasonYear = 2023
GROUP BY T.teamName;

SELECT * FROM TotalReboundsByTeamInSeason;

-- More Data
INSERT INTO Player (playerID, playerName, teamID, playerPosition)
VALUES 
    (3, 'Anthony Davis', 1, 'Center');

INSERT INTO PlayerStats (playerID, gameID, points, rebounds, assists, steals, blocks, turnovers, ft_percent, fg_percent, three_points)
VALUES 
    -- Game 1 stats
    (3, 1, 20, 12, 3, 1, 2, 2, 80.0, 60.0, 0),
    -- Game 2 stats
    (3, 2, 22, 10, 4, 2, 3, 3, 78.0, 55.0, 1);

-- highest FT% by a player?
-- Creating the view for Highest FT% by Player
CREATE OR REPLACE VIEW HighestFTPercentByPlayer AS
SELECT P.playerName, AVG(PS.ft_percent) AS avg_ft_percent
FROM PlayerStats PS
JOIN Player P ON PS.playerID = P.playerID
JOIN Game G ON PS.gameID = G.gameID
JOIN Season S ON G.game_date BETWEEN S.startDate AND S.endDate
WHERE S.seasonYear = 2023
GROUP BY P.playerName
ORDER BY avg_ft_percent DESC
LIMIT 10;

SELECT * FROM HighestFTPercentByPlayer;

-- Index Identification Creations
-- Player Table: Index on teamID
CREATE INDEX idx_player_teamID 
	ON Player(teamID);

-- PlayerStats Table: Index on playerID and gameID
CREATE INDEX idx_playerstats_playerID 
	ON PlayerStats(playerID);
CREATE INDEX idx_playerstats_gameID 
	ON PlayerStats(gameID);

-- TeamStats Table: Index on teamID and gameID
CREATE INDEX idx_teamstats_teamID 
	ON TeamStats(teamID);
CREATE INDEX idx_teamstats_gameID 
	ON TeamStats(gameID);

-- Injury Table: Index on playerID
CREATE INDEX idx_injury_playerID 
	ON Injury(playerID);

-- Season Table: Index on seasonYear
CREATE INDEX idx_season_seasonYear 
	ON Season(seasonYear);

-- 'teamID' is the primary key for the Team table
CREATE INDEX idx_team_teamID ON Team(teamID);

-- Update the Game table to include seasonID as a foreign key
ALTER TABLE Game
ADD COLUMN seasonID INT REFERENCES Season(seasonID);
-- Index on the foreign key 'seasonID' in the Game table
CREATE INDEX idx_game_seasonID ON Game(seasonID);

-- Indexes for foreign keys
CREATE INDEX idx_player_teamID ON Player(teamID);
CREATE INDEX idx_playerstats_playerID ON PlayerStats(playerID);
CREATE INDEX idx_playerstats_gameID ON PlayerStats(gameID);
CREATE INDEX idx_teamstats_teamID ON TeamStats(teamID);
CREATE INDEX idx_teamstats_gameID ON TeamStats(gameID);
CREATE INDEX idx_division_conferenceID ON Division(conferenceID);

-- Sample Data
SELECT injuryID FROM Injury;
ALTER TABLE Injury ALTER COLUMN recoverytime DROP NOT NULL;
-- Insert injuries for playerID 2 with unique injuryID values
INSERT INTO Injury (injuryID, playerID, gameID, injuryType, startDate, endDate, status, recoveryTime)
VALUES 
    (5, 2, 1, 'Ankle Sprain', '2023-02-15', '2023-02-25', 'Recovered', 10),
    (6, 2, 2, 'Hamstring Strain', '2023-03-01', NULL, 'Ongoing', NULL);

-- Insert injuries for playerID 3 with unique injuryID values
INSERT INTO Injury (injuryID, playerID, gameID, injuryType, startDate, endDate, status, recoveryTime)
VALUES 
    (7, 3, 1, 'Shoulder Dislocation', '2023-03-10', NULL, 'Ongoing', NULL),
    (8, 3, 2, 'Knee Contusion', '2023-04-01', '2023-04-10', 'Recovered', 9);

SELECT * FROM Injury;

-- Data for Recovery
-- Recovery for Shoulder Dislocation (injuryID 1)
INSERT INTO pRecovery (recoveryID, injuryID, startDate, endDate, status)
VALUES 
(1, 1, '2023-03-11', NULL, 'Ongoing');
-- Recovery for Ankle Sprain (injuryID 2)
INSERT INTO pRecovery (recoveryID, injuryID, startDate, endDate, status)
VALUES 
(2, 2, '2023-02-15', '2023-02-25', 'Recovered');
-- Recovery for Hamstring Strain (injuryID 3)
INSERT INTO pRecovery (recoveryID, injuryID, startDate, endDate, status)
VALUES 
(3, 3, '2023-03-01', NULL, 'Ongoing');

-- Recovery for Knee Contusion (injuryID 5)
INSERT INTO pRecovery (recoveryID, injuryID, startDate, endDate, status)
VALUES 
(5, 5, '2023-04-01', '2023-04-10', 'Recovered');
-- Recovery for Hamstring Strain (injuryID 6)
INSERT INTO pRecovery (recoveryID, injuryID, startDate, endDate, status)
VALUES 
(6, 6, '2023-01-02', '2023-01-15', 'Recovered');
-- Recovery for Ankle Sprain (injuryID 7)
INSERT INTO pRecovery (recoveryID, injuryID, startDate, endDate, status)
VALUES 
(7, 7, '2023-02-05', '2023-02-20', 'Recovered');

-- History Tables
-- Create PlayerInjuryHistory Table
CREATE SEQUENCE history_seq START 1;
CREATE TABLE PlayerInjuryHistory (
    injuryHistoryID INT PRIMARY KEY DEFAULT NEXTVAL('history_seq'),
    playerID INT NOT NULL REFERENCES Player(playerID),
    injuryID INT NOT NULL REFERENCES Injury(injuryID),
    recoveryID INT NOT NULL REFERENCES pRecovery(recoveryID),
    impactOnPerformance VARCHAR(255),
    recoveryDuration INTERVAL,
    performanceAfterRecovery VARCHAR(255),
    recordedOn TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DROP TRIGGER IF EXISTS trg_injury_history ON Injury;
DROP FUNCTION IF EXISTS track_injury_history;
-- Create the Trigger Function to Track Injury History
CREATE OR REPLACE FUNCTION track_injury_history() RETURNS TRIGGER AS $$
DECLARE
    recID INT;
BEGIN
    -- Find recoveryID for the given injuryID
    SELECT recoveryID INTO recID 
    FROM pRecovery 
    WHERE injuryID = NEW.injuryID 
    LIMIT 1;

    -- If no recoveryID is found, raise an error or handle it accordingly
    IF recID IS NULL THEN
        RAISE EXCEPTION 'No recoveryID found for injuryID %', NEW.injuryID;
    END IF;

    -- Insert a record into PlayerInjuryHistory when the injury status changes
    IF OLD.status <> NEW.status THEN
        INSERT INTO PlayerInjuryHistory (
            playerID, injuryID, recoveryID, impactOnPerformance, recoveryDuration, performanceAfterRecovery, recordedOn
        )
        VALUES (
            NEW.playerID,
            NEW.injuryID,
            recID,  -- Use the local variable for recoveryID
            'Impact to be evaluated',
            (NEW.endDate - NEW.startDate) * INTERVAL '1 day', -- Cast to INTERVAL
            'Performance after recovery to be determined',
            NOW()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the Trigger on the Injury Table
CREATE TRIGGER trg_injury_history
AFTER UPDATE OF status ON Injury
FOR EACH ROW
EXECUTE FUNCTION track_injury_history();

-- Verify Trigger Execution with Example 1
-- Update Injury status to 'Recovered'
UPDATE Injury
SET status = 'Recovered'
WHERE injuryID = 3;

-- Verify history record
SELECT * FROM PlayerInjuryHistory
WHERE injuryID = 3;

-- Verify Trigger Execution with Example 2
-- Update Injury status to 'In Recovery'
UPDATE Injury
SET status = 'In Recovery', 
    endDate = '2023-03-20',
    recoveryTime = 19
WHERE injuryID = 3;

-- Verify Trigger Execution with Example 3
-- Update Injury status to 'Recovered'
UPDATE Injury
SET status = 'Recovered', 
    endDate = '2023-03-25',
    recoveryTime = 24
WHERE injuryID = 3;

-- Update Data
-- Update injury records to ensure consistency with pRecovery
UPDATE Injury
SET endDate = '2023-02-25', recoveryTime = 10
WHERE injuryID = 5 AND injuryType = 'Ankle Sprain';

UPDATE Injury
SET endDate = '2023-04-10', recoveryTime = 9
WHERE injuryID = 8 AND injuryType = 'Knee Contusion';

UPDATE Injury
SET endDate = '2023-02-20', recoveryTime = 15
WHERE injuryID = 2 AND injuryType = 'Ankle Sprain';

UPDATE Injury
SET endDate = '2023-03-20', recoveryTime = 24
WHERE injuryID = 3 AND injuryType = 'Shoulder Dislocation';

UPDATE Injury
SET endDate = '2023-04-15', recoveryTime = 14
WHERE injuryID = 1 AND injuryType = 'Hamstring Strain';

UPDATE Injury
SET endDate = '2023-04-14', recoveryTime = 35
WHERE injuryID = 7 AND injuryType = 'Shoulder Dislocation';

UPDATE Injury
SET endDate = '2023-03-14', recoveryTime = 13
WHERE injuryID = 6 AND injuryType = 'Hamstring Strain';

-- If there are any ongoing injuries that should be marked as recovered, update them as well:
UPDATE Injury
SET endDate = '2023-04-05', recoveryTime = 16, status = 'Recovered'
WHERE injuryID = 9 AND injuryType = 'Ankle Sprain';

-- For any injuries that are still ongoing, ensure that the recovery time is not null:
UPDATE Injury
SET recoveryTime = 8 -- or another appropriate value
WHERE injuryID = 4 AND injuryType = 'Knee Contusion';

-- Update pRecovery records to ensure consistency with Injury
UPDATE pRecovery
SET endDate = '2023-02-25', status = 'Recovered'
WHERE injuryID = 5 AND recoveryID = 1;

UPDATE pRecovery
SET endDate = '2023-04-10', status = 'Recovered'
WHERE injuryID = 8 AND recoveryID = 2;

UPDATE pRecovery
SET endDate = '2023-02-20', status = 'Recovered'
WHERE injuryID = 2 AND recoveryID = 3;

UPDATE pRecovery
SET endDate = '2023-03-20', status = 'Recovered'
WHERE injuryID = 3 AND recoveryID = 4;

UPDATE pRecovery
SET endDate = '2023-04-15', status = 'Recovered'
WHERE injuryID = 1 AND recoveryID = 5;

UPDATE pRecovery
SET endDate = '2023-04-14', status = 'Recovered'
WHERE injuryID = 7 AND recoveryID = 6;

UPDATE pRecovery
SET endDate = '2023-03-14', status = 'Recovered'
WHERE injuryID = 6 AND recoveryID = 7;

UPDATE pRecovery
SET endDate = '2023-04-05', status = 'Recovered'
WHERE injuryID = 9 AND recoveryID = 8;

-- SQL Queries for Injury History
-- Query 1: Retrieve All Injury History for a Specific Player
SELECT 
    P.playerName, 
    I.injuryType, 
    I.status AS currentStatus, 
    H.recoveryDuration, 
    H.performanceAfterRecovery, 
    H.recordedOn
FROM 
    PlayerInjuryHistory H
JOIN 
    Player P ON H.playerID = P.playerID
JOIN 
    Injury I ON H.injuryID = I.injuryID
WHERE 
    H.playerID = 1;

-- Query 2: Analyze average recovery duration by injury type
SELECT I.injuryType, AVG(H.recoveryDuration) AS avgRecoveryTime
FROM PlayerInjuryHistory H
JOIN Injury I ON H.injuryID = I.injuryID
GROUP BY I.injuryType;

-- Query 3: Count of Injuries by Type
SELECT I.injuryType, COUNT(*) AS TotalInjuries
FROM Injury I
GROUP BY I.injuryType
ORDER BY TotalInjuries DESC;

