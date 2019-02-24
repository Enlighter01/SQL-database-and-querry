CREATE DATABASE FudbalskaLiga
COLLATE Serbian_Latin_100_CI_AI
GO

USE FudbalskaLiga
GO

CREATE TABLE Tim
(
	TimId int IDENTITY(1,1) PRIMARY KEY,
	Naziv nvarchar(100) NOT NULL,
	Mesto nvarchar(100) NOT NULL
);

INSERT INTO Tim VALUES ('Mancherster United','Manchester');
INSERT INTO Tim VALUES ('Arsenal','London');
INSERT INTO Tim VALUES ('Inter','Milano');
INSERT INTO Tim VALUES ('Barselona','Barselona');
INSERT INTO Tim VALUES ('Milano','Milano')

CREATE TABLE Fudbaler 
(
FudbalerId int IDENTITY(1,1) PRIMARY KEY,
Ime nvarchar(70) NOT NULL,
Prezime nvarchar(70) NOT NULL,
TimId int FOREIGN KEY REFERENCES Tim(TimId) ON DELETE CASCADE
);

INSERT INTO Fudbaler VALUES ('Edwin','van der Sar',1);
INSERT INTO Fudbaler VALUES ('Rio','Ferdinand',1);
INSERT INTO Fudbaler VALUES ('Nemanja','Vidic',1);
INSERT INTO Fudbaler VALUES ('Wayne','Rooney',1);
INSERT INTO Fudbaler VALUES ('Darren','Fletcher',1);
INSERT INTO Fudbaler VALUES ('Cesc',' Fabregas',2);
INSERT INTO Fudbaler VALUES ('Dejan',' Stankovic',3);
INSERT INTO Fudbaler VALUES ('Lionel',' Messi',4);
INSERT INTO Fudbaler VALUES ('Zlatan', 'Ibrahimovic',4);
INSERT INTO Fudbaler VALUES ('Andres', 'Iniesta',4);
INSERT INTO Fudbaler VALUES ('Carles', 'Puyol',4);
INSERT INTO Fudbaler VALUES ('Ronaldinho','de Assis Moreira',5);
INSERT INTO Fudbaler VALUES ('Alexandre', 'Pato',5);
INSERT INTO Fudbaler VALUES ('Filippo', 'Inzaghi',5);
GO

SELECT * FROM Fudbaler;

CREATE TABLE Utakmica
(
UtakmicaId int IDENTITY(1,1) PRIMARY KEY,
DomacinId int NOT NULL FOREIGN KEY REFERENCES Tim(TimId),
GostId int NOT NULL FOREIGN KEY REFERENCES Tim(TimId),
Godina int NOT NULL,
Kolo nvarchar(30) NOT NULL,
Ishod char(1) NOT NULL,
CONSTRAINT CHK_Utakmica CHECK(DomacinId<>GostId)
);

-- Ishod: 1 = pobeda domacih, 2 = pobeda gostiju, x = nereseno

INSERT INTO Utakmica VALUES (2,1,2008,1,'1');
INSERT INTO Utakmica VALUES (3,5,2009,3,'2');
INSERT INTO Utakmica VALUES (1,4,2010,1,'X');
INSERT INTO Utakmica VALUES (1,5,2005,2,'X');
INSERT INTO Utakmica VALUES (5,3,2009,1,'2');

SELECT * FROM Utakmica;

CREATE VIEW View_RezultatiUtakmica
AS
SELECT  d.Naziv AS Domacin, g.Naziv AS Gost, u.Godina,
CASE u.Ishod
WHEN '1' THEN 'Pobeda Domacina'
WHEN '2' THEN 'Pobeda Gosta'
WHEN 'X' THEN 'Nereseno'
ELSE 'Greska'
END AS Ishod 
FROM Tim AS d
INNER JOIN  Utakmica AS u
ON u.DomacinId = d.TimId
INNER JOIN  Tim AS  g
ON u.GostId = g.TimId

SELECT * FROM View_RezultatiUtakmica
GO

CREATE TABLE  Igrao
(
	FudbalerId int  NOT NULL FOREIGN KEY REFERENCES Fudbaler(FudbalerId),
	UtakmicaId int NOT NULL FOREIGN KEY REFERENCES Utakmica(UtakmicaId),
	PozicijaIgraca varchar(2) NOT NULL
);

CREATE FUNCTION fn_FudbalerUtakmica 
(
@FudbalerId int,
@UtakmicaId int
)
RETURNS bit
AS
BEGIN
DECLARE @idDomacin int = 
(SELECT DomacinId
FROM Utakmica
WHERE UtakmicaId = @UtakmicaId);
DECLARE @idGost int = 
(SELECT GostId
FROM Utakmica
WHERE UtakmicaId = @UtakmicaId);
DECLARE @idTIm int= 
(SELECT TimId
FROM Fudbaler
WHERE FudbalerId = @FudbalerId
)
DECLARE @rez int = 0;
IF (@idTim = @idDomacin OR @idTIm = @idGost)
SET @rez =1;
RETURN @rez;
END

GO

SELECT dbo.fn_FudbalerUtakmica(8,5) AS Rezultat

ALTER TABLE Igrao
ADD CONSTRAINT CHK_FudbalerUtakmica
CHECK (dbo.fn_FudbalerUtakmica(FudbalerId,UtakmicaId)=1)
GO

INSERT INTO Igrao VALUES (1,1,'1');
INSERT INTO Igrao VALUES (2,1,'5');
INSERT INTO Igrao VALUES (3,1,'4');
INSERT INTO Igrao VALUES (4,1,'8');
INSERT INTO Igrao VALUES (5,1,'3');
INSERT INTO Igrao VALUES (6,1,'3');
INSERT INTO Igrao VALUES (12,2,'2');
INSERT INTO Igrao VALUES (13,2,'1');
INSERT INTO Igrao VALUES (1,3,'1');
INSERT INTO Igrao VALUES (2,3,'5');
INSERT INTO Igrao VALUES (3,3,'15');
INSERT INTO Igrao VALUES (4,3,'10');
INSERT INTO Igrao VALUES (5,3,'24');
INSERT INTO Igrao VALUES (8,3,'6');
INSERT INTO Igrao VALUES (9,3,'7');
INSERT INTO Igrao VALUES (10,3,'8');
INSERT INTO Igrao VALUES (11,3,'9');
INSERT INTO Igrao VALUES (1,4,'1');
INSERT INTO Igrao VALUES (2,4,'5');
INSERT INTO Igrao VALUES (3,4,'15');
INSERT INTO Igrao VALUES (4,4,'10');
INSERT INTO Igrao VALUES (5,4,'24');
INSERT INTO Igrao VALUES (12,4,'4');
INSERT INTO Igrao VALUES (13,4,'9');
INSERT INTO Igrao VALUES (14,4,'8');
INSERT INTO Igrao VALUES (12,5,'10');
INSERT INTO Igrao VALUES (13,5,'1');
INSERT INTO Igrao VALUES (14,5,'8');
INSERT INTO Igrao VALUES (7,5,'4');
GO

CREATE VIEW View_FudbaleriUtakmice
AS
SELECT dbo.Fudbaler.FudbalerId, dbo.Fudbaler.Ime, dbo.Fudbaler.Prezime, t1.Naziv AS [Tim
fudbalera], Domacin.Naziv AS Domacin, Gost.Naziv AS Gost
FROM dbo.Fudbaler INNER JOIN
dbo.Igrao ON dbo.Fudbaler.FudbalerId = dbo.Igrao.FudbalerId INNER JOIN
dbo.Utakmica ON dbo.Igrao.UtakmicaId = dbo.Utakmica.UtakmicaId INNER
JOIN
dbo.Tim AS t1 ON dbo.Fudbaler.TimId = t1.TimId INNER JOIN
dbo.Tim AS Domacin ON dbo.Utakmica.DomacinId = Domacin.TimId INNER JOIN
dbo.Tim AS Gost ON dbo.Utakmica.GostId = Gost.TimId
GO

SELECT * FROM View_FudbaleriUtakmice
ORDER BY FudbalerId

CREATE VIEW View_BrojUtakmica
AS
SELECT f.Ime, f.Prezime, COUNT(*) AS BrojUtakmica
FROM Fudbaler AS f
INNER JOIN Igrao AS i
ON f.FudbalerId = i.FudbalerId
GROUP BY f.Ime, f.Prezime;

GO

SELECT * FROM View_BrojUtakmica
ORDER BY BrojUtakmica DESC
GO

CREATE TABLE  Gol
(
	GolId int IDENTITY (1,1) PRIMARY KEY,
	UtakmicaId int NOT NULL FOREIGN KEY REFERENCES Utakmica(UtakmicaId),
	FudbalerId int NOT NULL FOREIGN KEY REFERENCES Fudbaler(FudbalerId),
	RedniBrGola int NOT NULL,
	Minut int NOT NULL
);

ALTER TABLE Gol
ADD CONSTRAINT CHK_FudbalerUtakmica1
CHECK (dbo.fn_FudbalerUtakmica(FudbalerId,UtakmicaId)=1)

INSERT INTO Gol VALUES (1,2,1,14);
INSERT INTO Gol VALUES (1,2,2,38);
INSERT INTO Gol VALUES (1,6,3,75);
INSERT INTO Gol VALUES (1,3,4,84);
INSERT INTO Gol VALUES (2,12,1,67);
INSERT INTO Gol VALUES (3,3,1,56);
INSERT INTO Gol VALUES (3,9,1,15);
INSERT INTO Gol VALUES (5,14,1,29);
INSERT INTO Gol VALUES (5,7,2,59);
INSERT INTO Gol VALUES (5,7,3,64);

SELECT * FROM Gol;

CREATE VIEW View_BrGolova
AS
SELECT f.Ime, f.Prezime, COUNT(*) AS BrojGolova
FROM Fudbaler AS f
INNER JOIN Gol AS g
ON f.FudbalerId = g.FudbalerId
GROUP BY f.Ime, f.Prezime

GO

SELECT * FROM View_BrGolova
ORDER BY BrojGolova DESC
GO

GO
CREATE VIEW View_BrGolovaUgostima
AS
SELECT f.Ime, f.Prezime, COUNT(*) AS BrojGolova
FROM Fudbaler AS f
INNER JOIN Gol AS g
ON f.FudbalerId = g.FudbalerId
INNER JOIN Utakmica AS u
ON u.UtakmicaId = g.UtakmicaId
WHERE f.TimId = u.GostId
GROUP BY f.Ime, f.Prezime;

SELECT * FROM View_BrGolovaUgostima
ORDER BY BrojGolova DESC
GO

CREATE VIEW View_BrGolovaKuci
AS
SELECT f.Ime, f.Prezime, COUNT(*) AS BrojGolova
FROM Fudbaler AS f
INNER JOIN Gol AS g
ON f.FudbalerId = g.FudbalerId
INNER JOIN Utakmica AS u
ON u.UtakmicaId = g.UtakmicaId
WHERE f.TimId = u.DomacinId
GROUP BY f.Ime, f.Prezime;
GO

SELECT * FROM View_BrGolovaKuci
ORDER BY BrojGolova DESC

CREATE TABLE  Karton
(
	KartonId int IDENTITY(1,1) PRIMARY KEY,
	UtakmicaId int NOT NULL FOREIGN KEY REFERENCES Utakmica(UtakmicaId),
	FudbalerId int NOT NULL FOREIGN KEY REFERENCES Fudbaler(FudbalerId),
	Tip nvarchar(20) NOT NULL,
	Minut int NOT NULL
);

ALTER TABLE Karton
ADD CONSTRAINT CHK_FudbalerUtakmica2
CHECK (dbo.fn_FudbalerUtakmica(FudbalerId,UtakmicaId)=1)

INSERT INTO Karton VALUES (1,4,'zuti karton',53);
INSERT INTO Karton VALUES (1,3,'zuti karton',16);
INSERT INTO Karton VALUES (1,4,'crveni karton',84);
INSERT INTO Karton VALUES (3,2,'zuti karton',35);
INSERT INTO Karton VALUES (3,10,'zuti karton',58);
INSERT INTO Karton VALUES (4,13,'zuti karton',43);
INSERT INTO Karton VALUES (5,14,'zuti karton',73);

SELECT * FROM Karton
ORDER BY BrojGolova DESC

GO

CREATE VIEW View_BrojKartona
AS
SELECT f.Ime, f.Prezime, COUNT(*) AS BrojGolova
FROM Fudbaler AS f
INNER JOIN Karton AS k
ON f.FudbalerId = k.FudbalerId
GROUP BY f.Ime, f.Prezime;

SELECT * FROM View_BrojKartona

CREATE VIEW View_DaliGolNakonKartona
AS
SELECT f.Ime, f.Prezime, g.Minut, k.Minut AS Karton
FROM Fudbaler AS F
INNER JOIN Gol AS g
ON f.FudbalerId = g.FudbalerId
INNER JOIN  Karton AS k
ON f.FudbalerId = k.FudbalerId
WHERE (g.Minut > k.Minut AND k.Tip = 'zuri karton')

GO
SELECT * FROM View_DaliGolNakonKartona;