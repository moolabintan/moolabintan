import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import DatabaseUtilities.DatabaseConnectionService;

//Specifically for Spotify API use
//import com.example.spotify.SpotifyAuthorizationService;

public class PopulateApp {
    static String ConnectionServer = "MediaOrganizer";

    public static void main(String[] args) {
        try {
            // PopulateApp.populateVideoGames();
            // PopulateApp.populateMovies();
            PopulateApp.populateTVShows();
            PopulateApp.populateSongs();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println(e.getLocalizedMessage());
            System.out.println(e.getMessage());
        }
    }

    public static void populateVideoGames() throws Exception {
        DatabaseConnectionService database = new DatabaseConnectionService();
        if (database.connect("ApplicationProfile", "Password1234$", ConnectionServer) == false)
            return;
        CallableStatement callstmt = null;

        // Video game section
        URI uri = new URI(
                "https://api.steampowered.com/IStoreService/GetAppList/v1/?key=D1433259D99A91FBD3AF1FBDFAF8FF37&include_games=true&max_results=1000");
        HttpURLConnection con = (HttpURLConnection) uri.toURL().openConnection();
        con.setRequestMethod("GET");
        int responseCode = con.getResponseCode();

        int videogamesAdded = 0;

        if (responseCode == HttpURLConnection.HTTP_OK) {
            BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
            JsonObject json = (JsonObject) JsonParser.parseReader(in);
            in.close();

            JsonObject response = (JsonObject) json.get("response");
            JsonArray apps = (JsonArray) response.get("apps");

            ArrayList<String> appIds = new ArrayList<String>();

            for (int i = 0; i < 1000 && i < apps.size(); i++) {
                JsonObject current = (JsonObject) apps.get(i);
                appIds.add(current.get("appid").getAsString());
            }

            System.out.println("I have succesfully found " + appIds.size() + " total apps.");

            for (int i = 0; i < appIds.size(); i++) {
                URI appUri = new URI("https://store.steampowered.com/api/appdetails/?appids=" + appIds.get(i)
                        + "&filters=basic,publishers,developers,genres");
                HttpURLConnection appCon = (HttpURLConnection) appUri.toURL().openConnection();
                appCon.setRequestMethod("GET");
                int appResponseCode = appCon.getResponseCode();
                if (appResponseCode == HttpURLConnection.HTTP_OK) {
                    BufferedReader appIn = new BufferedReader(new InputStreamReader(appCon.getInputStream()));
                    JsonObject appJson = (JsonObject) JsonParser.parseReader(appIn);
                    appIn.close();

                    JsonObject specifics = (JsonObject) appJson.get(appIds.get(i));
                    JsonObject appData = (JsonObject) specifics.get("data");
                    if (appData == null) {
                        System.out.println("Hey, this isn't a real game");
                        System.out.println(appJson.toString());
                    } else if (appData.get("type").getAsString().equals("game")) {
                        callstmt = database.getConnection().prepareCall("{? = call insert_VideoGame(?, ?, ?, ?, ?)}");
                        callstmt.registerOutParameter(1, Types.INTEGER);
                        callstmt.registerOutParameter(6, Types.INTEGER);

                        String name = appData.get("name").getAsString();
                        if (name != null) {
                            if (name.length() > 100) {
                                name = name.substring(0, 100);
                            }
                            callstmt.setString(2, name);
                        } else {
                            callstmt.setNull(2, Types.NULL);
                        }

                        String description = appData.get("short_description").getAsString();
                        if (description != null) {
                            if (description.length() > 1000) {
                                description = description.substring((0), 1000);
                            }
                            callstmt.setString(3, description);
                        } else {
                            callstmt.setNull(3, Types.NULL);
                        }

                        String ageRating = appData.get("required_age").getAsString();
                        if (ageRating != null) {
                            callstmt.setString(4, ageRating);
                        } else {
                            callstmt.setNull(4, Types.NULL);
                        }

                        callstmt.setInt(5, Integer.valueOf(appIds.get(i)));

                        boolean returned = callstmt.execute();

                        if (callstmt.getLargeUpdateCount() != -1 || returned) {

                            int mid = callstmt.getInt(6);

                            JsonArray publishers = appData.getAsJsonArray("publishers");
                            if (publishers != null) {
                                for (JsonElement publisher : publishers) {
                                    callstmt = database.getConnection().prepareCall("{call insert_VG_Publisher(?, ?)}");
                                    callstmt.setInt(1, mid);
                                    callstmt.setString(2, publisher.getAsString());
                                    callstmt.execute();
                                }
                            }

                            JsonArray developers = appData.getAsJsonArray("developers");
                            if (developers != null) {
                                for (JsonElement developer : developers) {
                                    callstmt = database.getConnection().prepareCall("{call insert_VG_Developer(?, ?)}");
                                    callstmt.setInt(1, mid);
                                    callstmt.setString(2, developer.getAsString());
                                    callstmt.execute();
                                }
                            }

                            JsonArray genres = appData.getAsJsonArray("genres");
                            if (genres != null) {
                                for (JsonElement genre : genres) {
                                    callstmt = database.getConnection().prepareCall("{call insert_MediaGenres(?, ?)}");
                                    callstmt.setInt(1, mid);
                                    callstmt.setString(2, genre.getAsJsonObject().get("description").getAsString());
                                    callstmt.execute();
                                }
                            }

                            // System.out.println("I have added the app " + appIds.get(i));
                            videogamesAdded++;

                            if (videogamesAdded % 10 == 0) {
                                System.out.println(videogamesAdded + " games have been added so far");
                            }
                        }

                    }
                }
            }
        }

        System.out.println("I have added " + String.valueOf(videogamesAdded) + " video games");

        // -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        // Code below is to populate songs. Work in progress, I can't connect from
        // Eclipse for some reason

        // callstmt = database.getConnection().prepareCall("{call insertSong(?, ?, ?, ?,
        // ?, ?)}");
        // callstmt.registerOutParameter(5, Types.INTEGER);

        // //currently using a test playlist on my spotify to insert the sample data
        // uri = new
        // URI("spotify:user:v8fhalt4mmxjqb36t9v0gnk9d:playlist:69X92tNpmp3p9boDm7T005");

        // HttpURLConnection connection = (HttpURLConnection)
        // uri.toURL().openConnection();
        // connection.setRequestMethod("GET");
        // responseCode = connection.getResponseCode();
        // if (responseCode == HttpURLConnection.HTTP_OK) {
        // BufferedReader input = new BufferedReader(new
        // InputStreamReader(connection.getInputStream()));
        // JsonObject json = (JsonObject) JsonParser.parseReader(input);
        // input.close();

        // JsonObject response = (JsonObject) json.get("response");
        // JsonArray tracks = (JsonArray) response.get("id");

        // ArrayList<String> trackIds = new ArrayList<String>();

        // for (int i = 0; i < 500 && i < tracks.size(); i++) {
        // JsonObject current = (JsonObject) tracks.get(i);
        // trackIds.add(current.get("id").getAsString());
        // }

        // System.out.println("Initialized function.");
        // for (int i = 0; i < trackIds.size(); i++) {
        // URI appUri = new URI("spotify:track:" + trackIds.get(i) + "");
        // HttpURLConnection appCon = (HttpURLConnection)
        // appUri.toURL().openConnection();
        // appCon.setRequestMethod("GET");
        // int appResponseCode = appCon.getResponseCode();
        // if (appResponseCode == HttpURLConnection.HTTP_OK) {
        // BufferedReader appIn = new BufferedReader(new
        // InputStreamReader(appCon.getInputStream()));
        // JsonObject appJson = (JsonObject) JsonParser.parseReader(appIn);
        // appIn.close();

        // JsonObject specifics = (JsonObject) appJson.get(trackIds.get(i));
        // JsonObject appData = (JsonObject) specifics.get("data");

        // if (appData.get("type").getAsString().equals("track")) {
        // System.out.println(appData.toString());

        // //Name
        // String name = appData.get("name").getAsString();
        // if (name.length() > 100) {
        // name = name.substring(0, 100);
        // }
        // callstmt.setString(1, name);

        // //artist name
        // String artist = appData.get("artists.name").getAsString();
        // if (name.length() > 100) {
        // artist = artist.substring(0, 100);
        // }
        // callstmt.setString(2, artist);

        // //album name
        // String albumType = appData.get("album.album_group").getAsString();
        // if (albumType.equals("single")) {
        // callstmt.setNull(3, Types.NULL);
        // } else {
        // String albumName = appData.get("album.name").getAsString();
        // callstmt.setString(3, albumName);
        // }

        // //description
        // String description = "Released in ${date} by ${artist}.";
        // String releaseDate = appData.get("release_date").getAsString();
        // description.replace("${date}", releaseDate);
        // description.replace("${artist}", artist);
        // callstmt.setString(4, description);

        // //age rating
        // boolean isExplicit = appData.get("explicit").getAsBoolean();
        // if (isExplicit) {
        // callstmt.setString(5, "Explicit");
        // } else {
        // callstmt.setString(5, "Not Explicit");
        // }

        // //Output parameter set to null for now
        // callstmt.setNull(6, Types.NULL);

        // callstmt.execute();
        // }
        // }
        // }
        // }
        // System.out.println("Sample data songs added to DB");

        // -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        database.closeConnection();
    }

    public static void populateMovies() throws Exception {
        // Code below is to populate movies
        DatabaseConnectionService database = new DatabaseConnectionService();
        if (database.connect("ApplicationProfile", "Password1234$", ConnectionServer) == false)
            return;
        CallableStatement callstmt = null;

        callstmt = database.getConnection().prepareCall("{call AddMovies(?, ?, ?, ?, ?, ?, ?, ?, ?)}");
        callstmt.registerOutParameter(9, Types.INTEGER);

        // currently using a test playlist on my spotify to insert the sample data
        URI uri = new URI(
                "https://api.themoviedb.org/3/movie/top_rated?api_key=6dedcd97745400586f90889421da1197&language=en-US&page=9");

        HttpURLConnection connection = (HttpURLConnection) uri.toURL().openConnection();
        connection.setRequestMethod("GET");
        int responseCode = connection.getResponseCode();

        if (responseCode == HttpURLConnection.HTTP_OK) {
            BufferedReader input = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            JsonObject json = (JsonObject) JsonParser.parseReader(input);
            // System.out.println(json.toString());
            input.close();

            // JsonObject response = (JsonObject) json.get("results");
            JsonArray movies = (JsonArray) json.get("results");

            ArrayList<String> movieIds = new ArrayList<String>();

            for (int i = 0; i < 500 && i < movies.size(); i++) {
                JsonObject current = (JsonObject) movies.get(i);
                movieIds.add(current.get("id").getAsString());
            }

            System.out.println("Initialized function.");
            for (int i = 0; i < movieIds.size(); i++) {
                URI appUri = new URI("https://api.themoviedb.org/3/movie/" + movieIds.get(i)
                        + "?api_key=6dedcd97745400586f90889421da1197");
                HttpURLConnection appCon = (HttpURLConnection) appUri.toURL().openConnection();
                appCon.setRequestMethod("GET");
                int appResponseCode = appCon.getResponseCode();
                if (appResponseCode == HttpURLConnection.HTTP_OK) {

                    BufferedReader appIn = new BufferedReader(new InputStreamReader(appCon.getInputStream()));
                    JsonObject appJson = (JsonObject) JsonParser.parseReader(appIn);
                    appIn.close();

                    // JsonObject name = (JsonObject) appJson.get("name");

                    System.out.println(appJson.get("original_title"));

                    // JsonObject specifics = (JsonObject) appJson.get(movieIds.get(i));

                    // System.out.println(specifics);
                    // JsonObject appData = (JsonObject) specifics.get("data");

                    // System.out.println(appJson.toString());

                    String name = appJson.get("title").getAsString();
                    if (name.length() > 100) {
                        name = name.substring(0, 100);
                    }
                    callstmt.setString(1, name);

                    // user score
                    String score = appJson.get("vote_average").getAsString();
                    if (score.length() > 100) {
                        score = score.substring(0, 100);
                    }
                    callstmt.setString(2, score);

                    // description
                    String description = appJson.get("overview").getAsString();
                    if (description.length() > 1000) {
                        description = description.substring(0, 1000);
                    }
                    callstmt.setString(3, description);

                    // age rating
                    String rating = appJson.get("adult").getAsString();
                    callstmt.setString(4, rating);

                    // air date
                    String airDate = appJson.get("release_date").getAsString();
                    callstmt.setString(5, airDate);

                    // air date
                    int length = appJson.get("runtime").getAsInt();
                    callstmt.setInt(6, length);

                    callstmt.setNull(7, Types.NULL);

                    callstmt.setNull(8, Types.NULL);

                    boolean returned = callstmt.execute();

                    if (callstmt.getLargeUpdateCount() != -1 || returned) {

                        int mid = callstmt.getInt(9);

                        JsonArray genres = appJson.getAsJsonArray("genres");
                        if (genres != null) {
                            for (JsonElement genre : genres) {
                                callstmt = database.getConnection().prepareCall("{call insert_MediaGenres(?, ?)}");
                                callstmt.setInt(1, mid);
                                callstmt.setString(2, genre.getAsJsonObject().get("name").getAsString());
                                callstmt.execute();
                            }
                        }
                    }

                }
            }
        }
        System.out.println("Sample data movies added to DB");
        database.closeConnection();
    }

    public static void populateTVShows() throws Exception {
        // Code below is to populate movies
        DatabaseConnectionService database = new DatabaseConnectionService();
        if (database.connect("ApplicationProfile", "Password1234$", ConnectionServer) == false)
            return;
        CallableStatement callstmt = null;

        callstmt = database.getConnection().prepareCall("{call AddTVShow(?, ?, ?, ?, ?, ?, ?)}");
        callstmt.registerOutParameter(7, Types.INTEGER);

        // currently using a test playlist on my spotify to insert the sample data
        URI uri = new URI(
                "https://api.themoviedb.org/3/tv/top_rated?api_key=6dedcd97745400586f90889421da1197&language=en-US&page=10");

        HttpURLConnection connection = (HttpURLConnection) uri.toURL().openConnection();
        connection.setRequestMethod("GET");
        int responseCode = connection.getResponseCode();

        if (responseCode == HttpURLConnection.HTTP_OK) {
            BufferedReader input = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            JsonObject json = (JsonObject) JsonParser.parseReader(input);
            // System.out.println(json.toString());
            input.close();

            // JsonObject response = (JsonObject) json.get("results");
            JsonArray movies = (JsonArray) json.get("results");

            ArrayList<String> tvIds = new ArrayList<String>();

            for (int i = 0; i < 500 && i < movies.size(); i++) {
                JsonObject current = (JsonObject) movies.get(i);
                tvIds.add(current.get("id").getAsString());
            }

            System.out.println("Initialized function.");
            for (int i = 0; i < tvIds.size(); i++) {
                URI appUri = new URI("https://api.themoviedb.org/3/tv/" + tvIds.get(i)
                        + "?api_key=6dedcd97745400586f90889421da1197");
                HttpURLConnection appCon = (HttpURLConnection) appUri.toURL().openConnection();
                appCon.setRequestMethod("GET");
                int appResponseCode = appCon.getResponseCode();
                if (appResponseCode == HttpURLConnection.HTTP_OK) {
                    BufferedReader appIn = new BufferedReader(new InputStreamReader(appCon.getInputStream()));
                    JsonObject appJson = (JsonObject) JsonParser.parseReader(appIn);
                    appIn.close();

                    // JsonObject name = (JsonObject) appJson.get("name");

                    System.out.println(appJson.get("name"));

                    // JsonObject specifics = (JsonObject) appJson.get(movieIds.get(i));

                    // System.out.println(specifics);
                    // JsonObject appData = (JsonObject) specifics.get("data");

                    // System.out.println(appJson.toString());

                    String name = appJson.get("name").getAsString();
                    if (name.length() > 100) {
                        name = name.substring(0, 100);
                    }
                    callstmt.setString(1, name);

                    // user score
                    String score = appJson.get("vote_average").getAsString();
                    if (score.length() > 100) {
                        score = score.substring(0, 100);
                    }
                    callstmt.setString(2, score);

                    // description
                    String description = appJson.get("overview").getAsString();
                    if (description.length() > 1000) {
                        description = description.substring(0, 1000);
                    }
                    callstmt.setString(3, description);

                    // age rating
                    // String rating = appJson.get("adult").getAsString();
                    callstmt.setNull(4, Types.NULL);

                    // air date
                    String airDate = appJson.get("status").getAsString();
                    callstmt.setString(5, airDate);

                    // air date
                    int numSeasons = appJson.get("number_of_seasons").getAsInt();
                    callstmt.setInt(6, numSeasons);

                    // air date
                    // int length = appJson.get("runtime").getAsInt();
                    // callstmt.setInt(6, length);

                    // callstmt.setNull(7, Types.NULL);

                    // callstmt.setNull(8, Types.NULL);

                    boolean returned = callstmt.execute();

                    if (callstmt.getLargeUpdateCount() != -1 || returned) {

                        int mid = callstmt.getInt(7);

                        JsonArray genres = appJson.getAsJsonArray("genres");
                        if (genres != null) {
                            for (JsonElement genre : genres) {
                                callstmt = database.getConnection().prepareCall("{call insert_MediaGenres(?, ?)}");
                                callstmt.setInt(1, mid);
                                callstmt.setString(2, genre.getAsJsonObject().get("name").getAsString());
                                callstmt.execute();
                            }
                        }

                    }

                }
            }
        }
        System.out.println("Sample data tv shows added to DB");
        database.closeConnection();
    }

    public static void populateSongs() {
        DatabaseConnectionService database = new DatabaseConnectionService();
        CallableStatement callstmt = null;
        try {
            if (!database.connect("ApplicationProfile", "Password1234$", ConnectionServer)) {
                return;
            }

            callstmt = database.getConnection().prepareCall("{? = call InsertSong(?, ?, ?, ?, ?)}");
            callstmt.registerOutParameter(1, java.sql.Types.INTEGER);

            SpotifyAuthorizationService authorizationService = new SpotifyAuthorizationService();
            String accessToken = authorizationService.getAccessToken();

            String playlistID = "5FC89jdEdiySY06OTrkFNy";

            URI playlistUri = new URI("https://api.spotify.com/v1/playlists/" + playlistID);

            HttpURLConnection playlistConnection = (HttpURLConnection) playlistUri.toURL().openConnection();
            playlistConnection.setRequestMethod("GET");
            playlistConnection.setRequestProperty("Authorization", "Bearer " + accessToken);

            int playlistResponseCode = playlistConnection.getResponseCode();

            if (playlistResponseCode == HttpURLConnection.HTTP_OK) {

                try (BufferedReader input = new BufferedReader(
                        new InputStreamReader(playlistConnection.getInputStream()))) {
                    JsonObject json = (JsonObject) JsonParser.parseReader(input);

                    JsonArray songs = json.getAsJsonObject("tracks").getAsJsonArray("items");

                    ArrayList<String> songIds = new ArrayList<>();
                    System.out.println("# of songs = " + songs.size());

                    for (int i = 0; i < songs.size(); i++) {
                        JsonObject current = songs.get(i).getAsJsonObject();
                        songIds.add(current.getAsJsonObject("track").get("id").getAsString());
                    }

                    System.out.println("Initialized function.");

                    for (String songId : songIds) {
                        URI trackUri = new URI("https://api.spotify.com/v1/tracks/" + songId);
                        HttpURLConnection trackConnection = (HttpURLConnection) trackUri.toURL().openConnection();
                        trackConnection.setRequestMethod("GET");
                        trackConnection.setRequestProperty("Authorization", "Bearer " + accessToken);

                        int trackResponseCode = trackConnection.getResponseCode();

                        if (trackResponseCode == HttpURLConnection.HTTP_OK) {
                            try (BufferedReader trackIn = new BufferedReader(
                                    new InputStreamReader(trackConnection.getInputStream()))) {
                                JsonObject trackJson = (JsonObject) JsonParser.parseReader(trackIn);

                                String name = trackJson.get("name").getAsString();
                                System.out.println(name);
                                if (name.length() > 50) {
                                    name = name.substring(0, 50);
                                }
                                callstmt.setString(2, name);

                                JsonArray artists = trackJson.getAsJsonArray("artists");
                                String artist = artists.get(0).getAsJsonObject().get("name").getAsString();
                                if (artist.length() > 50) {
                                    artist = artist.substring(0, 50);
                                }
                                callstmt.setString(3, artist);

                                JsonObject album = trackJson.getAsJsonObject("album");
                                String albumName = album.get("name").getAsString();
                                if (albumName.length() > 50) {
                                    albumName = albumName.substring(0, 50);
                                }
                                callstmt.setString(4, albumName);

                                String desc = album.get("release_date").getAsString();
                                if (desc.length() > 100) {
                                    desc = desc.substring(0, 100);
                                }
                                callstmt.setString(5, desc);

                                boolean explicit = trackJson.get("explicit").getAsBoolean();
                                callstmt.setString(6, explicit ? "E" : null);

                                callstmt.execute();
                                int isDuplicate = callstmt.getInt(1);

                                if (isDuplicate == 1) {
                                    System.out.println("Duplicate song encountered: " + name + " by " + artist
                                            + " in album " + albumName);
                                    continue; // Skip to the next iteration of the loop
                                }

                            }
                        }
                    }
                }
            }
            System.out.println("Sample songs added to DB");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (callstmt != null) {
                try {
                    callstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (database != null) {
                database.closeConnection();
            }
        }
    }

}
