USE [MediaOrganizer_2];
GO

EXEC sp_addrolemember 'db_datareader', 'ApplicationProfile';
EXEC sp_addrolemember 'db_datawriter', 'ApplicationProfile';
GRANT EXECUTE TO [ApplicationProfile];
EXEC sp_addrolemember 'db_owner', 'frantzag';
EXEC sp_addrolemember 'db_owner', 'mcdonacj';
EXEC sp_addrolemember 'db_owner', 'olabinmo';

CREATE TABLE [dbo].[Album](
	[ID] INTEGER NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	[Artist_Name] VARCHAR(50) NOT NULL,
    PRIMARY KEY ([ID])
);

CREATE TABLE [dbo].[Media](
	[ID] INTEGER IDENTITY(0,1) NOT NULL,
	[Name] VARCHAR(100) NOT NULL,
	[UserScore] DECIMAL(10, 2) NULL,
	[Description] NVARCHAR(1000) NULL,
	[AgeRating] VARCHAR(5) NULL,
    PRIMARY KEY ([ID])
);

CREATE TABLE [dbo].[MediaGenres](
	[MediaID] INTEGER NOT NULL,
	[Genre] NVARCHAR(100) NOT NULL,
    PRIMARY KEY ([MediaID], [Genre]),
    FOREIGN KEY ([MediaID]) REFERENCES [dbo].[Media]([ID])
);

CREATE TABLE [dbo].[Movie](
	[ID] INTEGER NOT NULL,
	[AirDate] DATE NULL,
	[Length] INTEGER NOT NULL,
	[PrequelName] VARCHAR(100) NULL,
	[SequelName] VARCHAR(100) NULL,
    PRIMARY KEY ([ID]),
	FOREIGN KEY ([ID]) REFERENCES [dbo].[Media]([ID]),
    CHECK ([Length] > 0)
);

CREATE TABLE [dbo].[Song](
	[M_ID] INTEGER NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	[Artist Name] VARCHAR(50) NOT NULL,
	[AlbumID] INTEGER NULL,
    PRIMARY KEY ([M_ID]),
    FOREIGN KEY ([M_ID]) REFERENCES [dbo].[Media]([ID]),
    FOREIGN KEY ([AlbumID]) REFERENCES [dbo].[Album]([ID])
);

CREATE TABLE [dbo].[TV Show](
	[ID] INTEGER NOT NULL,
	[Status] VARCHAR(30) NULL,
	[NumSeasons] INTEGER NULL,
    PRIMARY KEY ([ID]),
    FOREIGN KEY ([ID]) REFERENCES [dbo].[Media]([ID])
        ON DELETE CASCADE,
    CHECK ([NumSeasons] > 0),
    CHECK (([Status]='On Air' OR [Status]='Cancelled' OR [Status]='Concluded'))
);

CREATE TABLE [dbo].[User](
	[ID] INTEGER IDENTITY(0,1) NOT NULL,
	[UserName] VARCHAR(100) NOT NULL,
	[PasswordSalt] VARCHAR(100) NOT NULL,
	[PasswordHash] VARCHAR(100) NOT NULL,
    UNIQUE ([ID]),
    UNIQUE ([UserName]),
    PRIMARY KEY ([ID])  
);

CREATE TABLE [dbo].[Review](
	[U_ID] INTEGER NOT NULL,
	[M_ID] INTEGER NOT NULL,
	[Score] INTEGER NULL,
	[Descrip] VARCHAR(300) NULL,
	[date published] DATETIME NULL,
    PRIMARY KEY ([U_ID], [M_ID]),
    FOREIGN KEY ([M_ID]) REFERENCES [dbo].[Media]([ID]),
    FOREIGN KEY ([U_ID]) REFERENCES [dbo].[User]([ID]),
    CHECK ([Score] >= 0 AND [Score] <= 100)
);

CREATE TABLE [dbo].[Video Game](
	[M_ID] INTEGER NOT NULL,
	[Steam_AppID] INTEGER NULL,
    UNIQUE ([Steam_AppID]),
    PRIMARY KEY ([M_ID]),
    FOREIGN KEY ([M_ID]) REFERENCES [dbo].[Media]([ID])
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE [dbo].[Developer](
	[M_ID] INTEGER NOT NULL,
	[DeveloperName] NVARCHAR(50) NOT NULL,
    PRIMARY KEY ([M_ID], [DeveloperName]),
    FOREIGN KEY ([M_ID]) REFERENCES [dbo].[Video Game]([M_ID])
);

CREATE TABLE [dbo].[Publisher](
	[M_ID] INTEGER NOT NULL,
	[PublisherName] NVARCHAR(50) NOT NULL,
    PRIMARY KEY ([M_ID], [PublisherName]),
    FOREIGN KEY ([M_ID]) REFERENCES [dbo].[Video Game]([M_ID])
);

CREATE NONCLUSTERED INDEX Media_Name_Index ON [dbo].[Media]([Name]);

GO

CREATE VIEW [dbo].[SongList]
AS
SELECT S.Name AS [SongTitle], S.[Artist Name] AS ArtistName, A.Name AS [AlbumName], M.UserScore, M.Description, M.AgeRating
FROM [Media] AS M
JOIN [Song] AS S ON M.ID = S.M_ID
JOIN [Album] AS A ON S.AlbumID = A.ID;

GO

CREATE VIEW [dbo].[VideoGames]
AS
SELECT Name, UserScore, Description, AgeRating
FROM [Media] m
JOIN [Video Game] vg ON m.ID = vg.M_ID

GO

CREATE Procedure AddMovies
	@name varchar(100),
	@userScore  varchar(100),
	@description nvarchar(1000),
	@ageRating varchar(5),
	@airDate date,
	@length int,
	@prequelName varchar(100),
	@sequelName varchar(100),
	@mid int OUTPUT
AS
BEGIN

	if @name is null or @name = ' '
	begin
		PRINT 'ERROR: Name can not be null or empty'
		Return (1)
	end

	Insert Into [MediaOrganizer].[dbo].[Media](Name, UserScore, Description, AgeRating)
	Values(@name, @userScore, @description, @ageRating)

	IF (@@ERROR != 0) BEGIN
	PRINT 'There was an error creating a new Media entry for your movie'
	RETURN (@@ERROR)
	END
	SET @mid = SCOPE_IDENTITY()
	Insert Into [MediaOrganizer].[dbo].[Movie](ID, AirDate, Length, PrequelName, SequelName)
	--need to figure out what to do with timestamp 
	Values(@mid, @airDate, @length, @prequelName, @sequelName)


END

GO

CREATE Procedure [dbo].[AddTvShow]
	@name varchar(100),
	@userScore  varchar(100),
	@description nvarchar(1000),
	@ageRating varchar(5),
	@status varchar(300),
	@numSeasons int,
	@mid int OUTPUT
AS
BEGIN

if @name is null or @name = ' '
	begin
		PRINT 'ERROR: Name can not be null or empty'
		Return (1)
	end
	
	Insert Into [MediaOrganizer].[dbo].[Media](Name, UserScore, Description, AgeRating)
	Values(@name, @userScore, @description, @ageRating)

	
	IF (@@ERROR != 0) BEGIN
	PRINT 'There was an error creating a new Media entry for your tv show'
	RETURN (@@ERROR)
	END


	SET @mid = SCOPE_IDENTITY()


	Insert Into [MediaOrganizer].[dbo].[TV Show](ID, Status, NumSeasons)
	Values(@mid, @status, @numSeasons)

END

GO

CREATE Procedure [dbo].[AddUser]
	@Username varchar(100),
	@PasswordSalt varchar(100),
	@PasswordHash varchar(100)
AS
BEGIN
	if @Username is null or @Username = ''
	BEGIN
		Print 'Username cannot be null or empty.';
		RETURN (1)
	END
	if @PasswordSalt is null or @PasswordSalt = ''
	BEGIN
		Print 'PasswordSalt cannot be null or empty.';
		RETURN (2)
	END
	if @PasswordHash is null or @PasswordHash = ''
	BEGIN
		Print 'PasswordHash cannot be null or empty.';
		RETURN (3)
	END
	IF (SELECT COUNT(*) FROM [User]
          WHERE Username = @Username) = 1
	BEGIN
      PRINT 'ERROR: Username already exists.';
	  RETURN(4)
	END
	INSERT INTO [User](Username, PasswordSalt, PasswordHash)
	VALUES (@username, @passwordSalt, @passwordHash)


END
GO

CREATE PROCEDURE [dbo].[delete_all_Media]
AS
BEGIN
    DELETE FROM Song;
    DELETE FROM Album;
    DELETE FROM Developer;
    DELETE FROM MediaGenres;
    DELETE FROM Movie;
    DELETE FROM Publisher;
    DELETE FROM Review;
    DELETE FROM [TV Show]
    DELETE FROM [Video Game]
    DELETE FROM [Media]
END
GO

CREATE PROCEDURE [dbo].[delete_all_VideoGames]
AS
BEGIN
    DELETE FROM [MediaGenres] WHERE EXISTS (SELECT * FROM [Video Game] WHERE [MediaID] = [M_ID])
    DELETE FROM [Publisher] WHERE EXISTS (SELECT * FROM [Video Game] WHERE [M_ID] = [M_ID])
    DELETE FROM [Developer] WHERE EXISTS (SELECT * FROM [Video Game] WHERE [M_ID] = [M_ID])

    DECLARE @TempTable TABLE(M_ID INT);
    INSERT INTO @TempTable(M_ID) (SELECT [M_ID] FROM [Video Game]);
    DELETE FROM [Video Game]  
    DELETE FROM [Media] WHERE EXISTS (SELECT * FROM @TempTable WHERE [M_ID] = [ID])
END
GO

CREATE PROCEDURE [dbo].[get_All_Reviews]
AS
    SELECT (CASE WHEN (mov.AirDate IS NOT NULL) THEN 'Movie' WHEN (song.AlbumID IS NOT NULL) THEN 'Song'
     WHEN (tv.[Status] IS NOT NULL) THEN 'TV Show' WHEN (vg.Steam_AppID IS NOT NULL) THEN 'Video Game' ELSE NULL END) AS [Media Type], 
    m.[Name], [Descrip] as [Review], [Score], m.ID
    FROM [Media] m
    JOIN [Review] rev ON rev.M_ID = m.ID
    LEFT JOIN [Movie] mov ON mov.ID = m.ID
    LEFT JOIN [Song] song ON song.M_ID = m.ID
    LEFT JOIN [TV Show] tv ON tv.ID = m.ID
    LEFT JOIN [Video Game] vg ON vg.M_ID = m.ID
GO

CREATE PROCEDURE [dbo].[get_music_album]
    @num_albums INT
AS
BEGIN
    SELECT TOP (@num_albums) [ID] AS ID, [Name] AS Name, [Artist_Name] AS Artist_Name
    FROM [dbo].[Album]
    ORDER BY [ID] ASC;
END
GO

CREATE PROCEDURE [dbo].[get_music_artist]
    @num_artists INT
AS
BEGIN
    SELECT TOP (@num_artists) MIN(M_ID) AS ID, [Artist Name] AS Name
    FROM [dbo].[Song]
    GROUP BY [Artist Name]
    ORDER BY [Artist Name]
END
GO

CREATE PROCEDURE [dbo].[get_music_genres]
    @num_genres INT
AS
BEGIN
    SELECT TOP (@num_genres)
        M.ID AS 'ID',
        S.Name AS 'Name',
        S.[Artist Name] AS 'Artist',
        M.Description AS 'Description',
        ISNULL(MG.Genre, 'N/A') AS 'Genre'
    FROM
        Media AS M
        INNER JOIN Song AS S ON M.ID = S.M_ID
        LEFT JOIN MediaGenres AS MG ON M.ID = MG.MediaID
    ORDER BY
        S.Name;
END
GO

CREATE PROCEDURE [dbo].[get_songs]
    @num_songs INT
AS
BEGIN
    SELECT TOP (@num_songs)
        S.M_ID AS ID,
        S.Name AS SongTitle,
        S.[Artist Name] AS ArtistName,
        A.Name AS AlbumName,
        M.Description,
        M.AgeRating,
        M.UserScore
    FROM
        [Song] AS S
        JOIN [Album] AS A ON S.AlbumID = A.ID
        JOIN [Media] AS M ON M.ID = S.M_ID
    ORDER BY S.Name ASC -- Order by SongTitle in alphabetical order
END
GO

CREATE PROCEDURE [dbo].[get_TVMovie] (
    @num_movies INTEGER
)
AS
    SELECT TOP (@num_movies) m.Name, m.UserScore, m.Description, m.AgeRating, m.ID
	FROM [Media] m
	JOIN Movie mv on mv.ID = m.ID
GO

CREATE PROCEDURE [dbo].[get_TVMovies] (
    @num_tvshows INTEGER
)
AS
    SELECT TOP (@num_tvshows) m.Name, m.UserScore, m.Description, m.AgeRating, m.ID
	FROM [Media] m
	JOIN [TV Show] tv on tv.ID = m.ID
GO

CREATE PROCEDURE [dbo].[get_User_Reviews] (
    @UserID INTEGER
)
AS
    SELECT (CASE WHEN (mov.AirDate IS NOT NULL) THEN 'Movie' WHEN (song.AlbumID IS NOT NULL) THEN 'Song'
     WHEN (tv.[Status] IS NOT NULL) THEN 'TV Show' WHEN (vg.Steam_AppID IS NOT NULL) THEN 'Video Game' ELSE NULL END) AS [Media Type], 
    m.[Name], [Descrip] as [Review], [Score], m.ID
    FROM [Media] m
    JOIN [Review] rev ON rev.M_ID = m.ID
    LEFT JOIN [Movie] mov ON mov.ID = m.ID
    LEFT JOIN [Song] song ON song.M_ID = m.ID
    LEFT JOIN [TV Show] tv ON tv.ID = m.ID
    LEFT JOIN [Video Game] vg ON vg.M_ID = m.ID
    WHERE rev.U_ID = @UserID
GO

CREATE PROCEDURE [dbo].[get_VG_Developers] (
    @num_games INTEGER
)
AS
    SELECT TOP (@num_games) Name, Description, DeveloperName, ID
    FROM [Media] m
    JOIN [Video Game] vg ON m.ID = vg.M_ID
    JOIN [Developer] dev ON dev.M_ID = m.ID
    ORDER BY Name
GO

CREATE PROCEDURE [dbo].[get_VG_Genres] (
    @num_games INTEGER
)
AS
    SELECT TOP (@num_games) Name, Description, Genre, ID
    FROM [Media] m
    JOIN [Video Game] vg ON m.ID = vg.M_ID
    JOIN [MediaGenres] mg ON mg.MediaID = m.ID
    ORDER BY Name
GO

CREATE PROCEDURE [dbo].[get_VG_Publishers] (
    @num_games INTEGER
)
AS
    SELECT TOP (@num_games) Name, Description, PublisherName, ID
    FROM [Media] m
    JOIN [Video Game] vg ON m.ID = vg.M_ID
    JOIN [Publisher] pub ON pub.M_ID = m.ID
    ORDER BY Name
GO

CREATE PROCEDURE [dbo].[get_VideoGames] (
    @num_games INTEGER,
    @Name_1 VARCHAR(100),
    @UserScore_2 DECIMAL(10, 2),
    @Description_3 NVARCHAR(1000),
    @AgeRating_4 NVARCHAR(7)
)
AS
BEGIN
    IF (@Name_1 IS NULL) SET @Name_1 = '%' ELSE SET @Name_1 = '%' + @Name_1 + '%';
    IF (@UserScore_2 IS NULL) SET @UserScore_2 = 0;
    IF (@Description_3 IS NULL) SET @Description_3 = '%' ELSE SET @Description_3 = '%' + @Description_3 + '%';
    IF (@AgeRating_4 IS NULL) SET @AgeRating_4 = '%' ELSE SET @AgeRating_4 = '%' + @AgeRating_4 + '%';
    SELECT TOP (@num_games) Name, UserScore, Description, AgeRating, ID
    FROM [Media] m
    JOIN [Video Game] vg ON m.ID = vg.M_ID
    WHERE ((Name LIKE @Name_1) AND (UserScore >= @UserScore_2 OR UserScore IS NULL) AND (Description LIKE @Description_3) AND (AgeRating LIKE @AgeRating_4 OR AgeRating IS NULL));
END
GO

CREATE PROCEDURE [dbo].[insert_MediaGenres] (
    @MediaID_1 INT,
    @Genre_2 NVARCHAR(100)
)
AS
BEGIN
    IF (@MediaID_1 IS NULL OR @Genre_2 IS NULL) BEGIN
        PRINT 'You must supply both @MediaID_1 and @Genre_2 for this procedure'
        RETURN(1);
    END

    IF NOT EXISTS (SELECT * FROM [dbo].[Media] WHERE ID = @MediaID_1) BEGIN
        PRINT 'The given media object doesn"t exist. Please create it first.';
        RETURN(2);
    END

    IF EXISTS (SELECT * FROM [dbo].[MediaGenres] WHERE MediaID = @MediaID_1 AND Genre = @Genre_2) BEGIN
        PRINT 'This media object already has the given genre';
        RETURN(3);
    END

    INSERT INTO [dbo].[MediaGenres](MediaID, Genre) VALUES (@MediaID_1, @Genre_2);

    IF (@@ERROR <> 0) BEGIN
        PRINT 'There was an error inserting the values into Media Genres';
        RETURN (@@ERROR);
    END

    PRINT 'Everything finished';
    RETURN(0);
END
GO

CREATE PROCEDURE [dbo].[insert_Music_Genre]
    @music_Name_1 VARCHAR(100),
    @NewGenre_2 NVARCHAR(100)
AS
BEGIN
    IF (@music_Name_1 IS NULL OR @NewGenre_2 IS NULL)
    BEGIN
        PRINT 'No null values are allowed for this function'
        RETURN(1);
    END

    DECLARE @music_ID INTEGER;
    SELECT @music_ID = M_ID
    FROM Song
    WHERE [Name] = @music_Name_1;

    IF (@music_ID IS NULL)
    BEGIN
        PRINT 'Song not found';
        RETURN(2);
    END

    EXEC insert_MediaGenres @music_ID, @NewGenre_2;
END
GO

CREATE PROCEDURE [dbo].[insert_User_Review](
	@U_ID_1 INT,
	@M_ID_2 INT,
    @Score_3 INT,
    @Descrip_4 NVARCHAR(300)
)
AS
BEGIN
	IF (@U_ID_1 IS NULL OR @M_ID_2 IS NULL) BEGIN
		PRINT 'The user id and media id must not be null'
		RETURN(1)
	END

	IF NOT (EXISTS(SELECT * FROM [User] WHERE [User].[ID] = @U_ID_1) AND EXISTS(SELECT * FROM [Media] WHERE [Media].[ID] = @M_ID_2)) BEGIN
		PRINT 'Either this user or this media entry don"t exist'
		RETURN(2)
	END

	DELETE FROM [Review] WHERE [Review].[M_ID] = @M_ID_2 AND [Review].[U_ID] = @U_ID_1

	IF (@@ERROR != 0) BEGIN
		PRINT 'There was an error deleting the old review'
		RETURN (@@ERROR)
	END

	INSERT INTO [Review](U_ID, M_ID, Score, Descrip, [date published]) VALUES (@U_ID_1, @M_ID_2, @Score_3, @Descrip_4, GETDATE())

	IF (@@ERROR != 0) BEGIN
		PRINT 'There was an error creating a new review for this media and user'
		RETURN (@@ERROR)
	END
END
GO

CREATE PROCEDURE [dbo].[insert_VG_Developer](
    @M_ID_1 INT,
    @DeveloperName_2 NVARCHAR(50)
)
AS
BEGIN
    IF (@M_ID_1 IS NULL OR @DeveloperName_2 IS NULL) BEGIN
        PRINT 'An ID and Name are required for this procedure';
        RETURN(1);
    END

    INSERT INTO [dbo].[Developer](M_ID, DeveloperName) VALUES (@M_ID_1, @DeveloperName_2);

    IF (@@ERROR <> 0) BEGIN
        PRINT 'There was an error adding this publisher';
        RETURN(@@ERROR);
    END

    PRINT 'Everything succeeded';

    RETURN(0);
END
GO

CREATE PROCEDURE insert_VG_Genre(
    @VideoGame_Name_1 VARCHAR(100),
    @NewGenre_2 NVARCHAR(100)
)
AS
BEGIN
    IF (@VideoGame_Name_1 IS NULL OR @NewGenre_2 IS NULL) BEGIN
        PRINT 'No null values are allowed for this function'
        RETURN(1);
    END

    DECLARE @VG_ID INTEGER;
    SELECT @VG_ID = [M_ID] FROM [Video Game]
    JOIN [Media] ON [M_ID] = [ID]
    WHERE [Media].[Name] = @VideoGame_Name_1;

    EXEC insert_MediaGenres @VG_ID, @NewGenre_2;
END
GO

CREATE PROCEDURE [dbo].[insert_VG_Publisher](
    @M_ID_1 INT,
    @PublisherName NVARCHAR(50)
)
AS
BEGIN
    IF (@M_ID_1 IS NULL OR @PublisherName IS NULL) BEGIN
        PRINT 'An ID and Name are required for this procedure';
        RETURN(1);
    END

    INSERT INTO [dbo].[Publisher](M_ID, PublisherName) VALUES (@M_ID_1, @PublisherName);

    IF (@@ERROR <> 0) BEGIN
        PRINT 'There was an error adding this publisher';
        RETURN(@@ERROR);
    END

    PRINT 'Everything succeeded';

    RETURN(0);
END;
GO

CREATE PROCEDURE [dbo].[insert_VideoGame](
	@Name_1 VARCHAR(100),
	@Description_2 NVARCHAR(1000),
    @Age_Rating_3 INT,
    @SteamID_4 INT,
	@ID_5 INT OUTPUT
)
AS
BEGIN
IF (@Name_1 IS NULL) BEGIN
	PRINT 'Your name value must not be NULL'
	RETURN(1)
END

INSERT INTO [Media](Name, Description, AgeRating) VALUES (@Name_1, @Description_2, @Age_Rating_3)

IF (@@ERROR != 0) BEGIN
	PRINT 'There was an error creating a new Media entry for your video game'
	RETURN (@@ERROR)
END

SET @ID_5 = SCOPE_IDENTITY()

INSERT INTO [Video Game]([M_ID], [Steam_AppID]) VALUES (@ID_5, @SteamID_4);

IF (@@ERROR != 0) BEGIN
	PRINT 'There was an error creating a new Video game entry'
	RETURN (@@ERROR)
END

END
GO

CREATE PROCEDURE [dbo].[InsertSong]
    @inpName VARCHAR(50),
    @inpArtist VARCHAR(50),
    @inpAlbum VARCHAR(50) = NULL,
    @desc NVARCHAR(MAX) = 'No description provided.',
    @rating VARCHAR(20) = 'N/A'
AS
BEGIN
    -- Check if inpName and inpArtist are null, if so exit
    IF (@inpName IS NULL OR @inpArtist IS NULL)
    BEGIN
        RAISERROR('Error: Name and Artist cannot be null', 16, 1)
        RETURN
    END

    -- Check if the song already exists in the Song table and Album table.
    IF EXISTS (SELECT 1 FROM Song WHERE Name = @inpName AND [Artist Name] = @inpArtist)
    BEGIN
        -- Check if the album exists in the Album table
        IF (@inpAlbum IS NOT NULL AND EXISTS (SELECT 1 FROM Album WHERE Name = @inpAlbum AND Artist_Name = @inpArtist))
        BEGIN
            -- The song released in this album by this artist already exists, reject the insert
            SELECT 1 AS IsDuplicate
            RETURN
        END
    END
    
    DECLARE @mediaID INT, @albumID INT

    -- Generate unique IDs for Media, Album, and Song - starting at 0 and incrementing until ID is unique
    SET @mediaID = 0
    WHILE EXISTS (SELECT 1 FROM Media WHERE ID = @mediaID)
    BEGIN
        SET @mediaID = (SELECT MAX(ID) FROM Media) + 1
    END
    
    SET @albumID = 0
    WHILE EXISTS (SELECT 1 FROM Album WHERE ID = @albumID)
    BEGIN
        SET @albumID = (SELECT MAX(ID) FROM Album) + 1
    END

    -- Insert values into Media
    INSERT INTO Media (Name, Description, AgeRating) VALUES (@inpName, @desc, @rating)
    SET @mediaID = SCOPE_IDENTITY()
    
    -- Check if inpAlbum is not null, then begin inserting into album
    IF (@inpAlbum IS NOT NULL)
    BEGIN
        -- Check if inpAlbum exists in Album table
        SET @albumID = (SELECT ID FROM Album WHERE Name = @inpAlbum)
        
        -- If inpAlbum does not exist, generate a unique ID for Album
        IF (@albumID IS NULL)
        BEGIN
            SET @albumID = 0
            WHILE EXISTS (SELECT 1 FROM Album WHERE ID = @albumID)
            BEGIN
                SET @albumID = @albumID + 1
            END
            
            -- Insert values into Album
            INSERT INTO Album (ID, Name, Artist_Name) VALUES (@albumID, @inpAlbum, @inpArtist)
        END
        ELSE
        BEGIN
            -- Update Album with inpArtist
            UPDATE Album SET Artist_Name = @inpArtist WHERE ID = @albumID
        END
        
        -- Insert values into Song
        INSERT INTO Song (M_ID, Name, [Artist Name], AlbumID) VALUES (@mediaID, @inpName, @inpArtist, @albumID)
    END
    ELSE
    BEGIN
        -- Insert values into Song with AlbumID as NULL - Skip past inserting into album
        -- functionality for assigning songs to albums can come later
        INSERT INTO Song (M_ID, Name, [Artist Name], AlbumID) VALUES (@mediaID, @inpName, @inpArtist, NULL)
   END
   -- The song is not a duplicate
	SELECT 0 AS IsDuplicate
	RETURN
END
GO

CREATE PROCEDURE [dbo].[RemoveSong]
    @inpName VARCHAR(50),
    @inpArtist VARCHAR(50)
AS
BEGIN
    -- Check if inpName and inpArtist are null, if so exit
    IF (@inpName IS NULL OR @inpArtist IS NULL)
    BEGIN
        RAISERROR('Error: Name and Artist cannot be null', 16, 1)
        RETURN
    END
    
    DECLARE @mediaID INT, @albumID INT

    -- Get the Media ID and Album ID for the Song to be deleted
    SELECT @mediaID = M_ID, @albumID = AlbumID FROM Song WHERE Name = @inpName AND [Artist Name] = @inpArtist

    -- Check if the Song exists in the Song table
    IF (@mediaID IS NULL)
    BEGIN
        RAISERROR('Error: Song not found', 16, 1)
        RETURN
    END

    -- Delete the Song from the Song table
    DELETE FROM Song WHERE Name = @inpName AND [Artist Name] = @inpArtist

    -- Check if the Album ID is not null, and if so, remove the Song from the Album
    IF (@albumID IS NOT NULL)
    BEGIN
        DELETE FROM Song WHERE M_ID = @mediaID AND AlbumID = @albumID

        -- Check if the Album has any remaining Songs, and if not, delete the Album
        IF NOT EXISTS (SELECT 1 FROM Song WHERE AlbumID = @albumID)
        BEGIN
            DELETE FROM Album WHERE ID = @albumID
        END
    END

    -- Delete the Media from the Media table
    DELETE FROM Media WHERE ID = @mediaID

    -- Return 0 to indicate success
    RETURN 0
END
GO

CREATE PROCEDURE [dbo].[SelectTopSongs]
    @n INT
AS
BEGIN
    SELECT TOP (@n) Song.[Artist Name], Song.Name AS SongName, Media.[UserScore], ISNULL(Album.Name, 'Single') AS AlbumName
    FROM Song
    INNER JOIN Media ON Song.M_ID = Media.ID
    LEFT JOIN Album ON Song.AlbumID = Album.ID
    ORDER BY Song.[Artist Name] DESC;
END
GO

CREATE PROCEDURE [dbo].[update_song](
    @ID_1 INT,
	@Name_2 VARCHAR(50) = NULL,
	@ArtistName_3 VARCHAR(50) = NULL,
	@AlbumID_4 INT = NULL,
	@Description_5 NVARCHAR(1000) = NULL,
    @Age_Rating_6 INT = NULL,
    @UserScore_7 DECIMAL(10, 2) = NULL
)
AS
BEGIN
	
	--Check if ID exists in table
	IF (NOT EXISTS(SELECT * FROM [Song] WHERE M_ID = @ID_1))
	BEGIN
		PRINT 'Error: ID does not match with any song'
		RETURN 1
	END

	--Check if user score is valid
	IF (@UserScore_7 IS NOT NULL AND @UserScore_7 < 0)
	BEGIN
		PRINT 'Error: User Score is invalid'
		RETURN 2
	END

	--Get name
	DECLARE @Name_Original VARCHAR(100)
    SELECT @Name_Original = Name FROM [Media] WHERE [ID] = @ID_1;

	--Get artist
	DECLARE @Artist_Original VARCHAR(50)
    SELECT @Artist_Original = Name FROM [Song] WHERE [M_ID] = @ID_1;

	--get album, if albumID in song is not null
	DECLARE @AlbumID_Original INT
	SELECT @AlbumID_Original = AlbumID FROM Song WHERE M_ID = @ID_1
	

	--get user score
	DECLARE @UserScore_Original DECIMAL(10, 2)
    SELECT @UserScore_Original = UserScore FROM [Media] WHERE [ID] = @ID_1;

	--get description
	DECLARE @Description_Original NVARCHAR(1000)
    SELECT @Description_Original = [Description] FROM [Media] WHERE [ID] = @ID_1;

	--get age rating
	DECLARE @AgeRating_Original NVARCHAR(5)
    SELECT @AgeRating_Original = AgeRating FROM [Media] WHERE [ID] = @ID_1;

	--update Media
	UPDATE [Media]
    SET
        [Name] = CASE WHEN (@Name_2 IS NOT NULL) THEN @Name_2 ELSE @Name_Original END,
        [UserScore] = CASE WHEN (@UserScore_7 IS NOT NULL) THEN @UserScore_7 ELSE @UserScore_Original END,
        [Description] = CASE WHEN (@Description_5 IS NOT NULL) THEN @Description_5 ELSE @Description_Original END,
        [AgeRating] = CASE WHEN (@Age_Rating_6 IS NOT NULL) THEN @Age_Rating_6 ELSE @AgeRating_Original END
    WHERE ID = @ID_1

	--update album
	--TODO: Add code here

	--update Song
	UPDATE [Song]
    SET
		[Name] = CASE WHEN (@Name_2 IS NOT NULL) THEN @Name_2 ELSE @Name_Original END,
		[Artist Name] = CASE WHEN (@ArtistName_3 IS NOT NULL) THEN @ArtistName_3 ELSE @Artist_Original END,
        [AlbumID] = CASE WHEN (@AlbumID_4 IS NOT NULL) THEN @AlbumID_4 ELSE @AlbumID_Original END
	WHERE M_ID = @ID_1


	--Last error check
	IF (@@ERROR != 0) BEGIN
        PRINT 'There was an error updating the new Media and Song entry for your song'
        RETURN (@@ERROR)
    END

END
GO

CREATE PROCEDURE [dbo].[update_VideoGame](
    @ID_1 INT,
	@Name_2 VARCHAR(100) = NULL,
	@Description_3 NVARCHAR(1000) = NULL,
    @Age_Rating_4 INT = NULL,
    @UserScore_5 DECIMAL(10, 2) = NULL
)
AS
BEGIN
    IF (NOT EXISTS(SELECT * FROM [Video Game] WHERE M_ID = @ID_1)) BEGIN
        PRINT 'This game doesn"t exist'
        RETURN(1)
    END

    IF (@UserScore_5 IS NOT NULL AND @UserScore_5 < 0) BEGIN
        PRINT 'This is not a valid user score'
        RETURN(2)
    END

    IF (@Age_Rating_4 IS NOT NULL AND @Age_Rating_4 < 0) BEGIN
        PRINT 'This is not a valid Age Rating'
        RETURN(3)
    END

    DECLARE @Name_Original VARCHAR(100)
    SELECT @Name_Original = Name FROM [Media] WHERE [ID] = @ID_1;

    DECLARE @UserScore_Original DECIMAL(10, 2)
    SELECT @UserScore_Original = UserScore FROM [Media] WHERE [ID] = @ID_1;

    DECLARE @Description_Original NVARCHAR(1000)
    SELECT @Description_Original = [Description] FROM [Media] WHERE [ID] = @ID_1;

    DECLARE @AgeRating_Original NVARCHAR(5)
    SELECT @AgeRating_Original = AgeRating FROM [Media] WHERE [ID] = @ID_1;

    UPDATE [Media]
    SET
        [Name] = CASE WHEN (@Name_2 IS NOT NULL) THEN @Name_2 ELSE @Name_Original END,
        [UserScore] = CASE WHEN (@UserScore_5 IS NOT NULL) THEN @UserScore_5 ELSE @UserScore_Original END,
        [Description] = CASE WHEN (@Description_3 IS NOT NULL) THEN @Description_3 ELSE @Description_Original END,
        [AgeRating] = CASE WHEN (@Age_Rating_4 IS NOT NULL) THEN @Age_Rating_4 ELSE @AgeRating_Original END
    WHERE ID = @ID_1

    IF (@@ERROR != 0) BEGIN
        PRINT 'There was an error updating the new Media entry for your video game'
        RETURN (@@ERROR)
    END

END
GO

CREATE PROCEDURE get_User_Salt (
    @UserName_1 VARCHAR(100),
    @PasswordSalt_2 VARCHAR(100) OUTPUT
)
AS
BEGIN
    IF (@UserName_1 IS NULL) BEGIN
        PRINT 'The username provided must not be null';
        RETURN(1);
    END

    SET @PasswordSalt_2 = NULL;

    SELECT @PasswordSalt_2 = [PasswordSalt] FROM [User] WHERE [UserName] = @UserName_1;

    IF (@PasswordSalt_2 IS NULL) BEGIN
        PRINT 'The user with that username does not exist';
        RETURN(2);
    END

    RETURN(0);
END
GO

CREATE PROCEDURE get_User_ID (
    @UserName_1 VARCHAR(100),
    @PasswordHash_2 VARCHAR(100),
    @UserID_3 INT OUTPUT
)
AS
BEGIN
    IF (@UserName_1 IS NULL OR @PasswordHash_2 IS NULL) BEGIN
        PRINT 'The username and password hash must not be null'
        RETURN(1)
    END

    SET @UserID_3 = NULL;

    SELECT @UserID_3 = [User].ID FROM [User] WHERE (@UserName_1 = [UserName] AND @PasswordHash_2 = [PasswordHash]);

    IF (@UserID_3 IS NULL) BEGIN
        PRINT 'This user does not exist'
        RETURN(2)
    END

    RETURN(0);
    
END
GO

CREATE PROCEDURE [dbo].[get_TV_Genres] (
    @num_shows INTEGER
)
AS
    SELECT TOP (@num_shows) Name, Description, Genre
    FROM [Media] m
    JOIN [TV Show] tv ON m.ID = tv.ID
    JOIN [MediaGenres] mg ON mg.MediaID = m.ID
    ORDER BY Name
GO

CREATE PROCEDURE [dbo].[get_MV_Genres] (
    @num_movies INTEGER
)
AS
    SELECT TOP (@num_movies) Name, Description, Genre
    FROM [Media] m
    JOIN [Movie] mv ON m.ID = mv.ID
    JOIN [MediaGenres] mg ON mg.MediaID = m.ID
    ORDER BY Name
GO
