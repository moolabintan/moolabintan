import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.util.Base64;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

//spotify API is annoying, so I need this other class for now to get the authorization code.

public class SpotifyAuthorizationService {
    private static final String CLIENT_ID = "9b5a2896eedc4bf7ad36347317c09c9f";
    private static final String CLIENT_SECRET = "9ea308b5efaa49bebb72085aff015256";
    
    public static String getAccessToken() throws Exception {
        String credentials = CLIENT_ID + ":" + CLIENT_SECRET;
        String encodedCredentials = Base64.getEncoder().encodeToString(credentials.getBytes());

        URI uri = new URI("https://accounts.spotify.com/api/token");
        HttpURLConnection connection = (HttpURLConnection) uri.toURL().openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Authorization", "Basic " + encodedCredentials);
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        connection.setDoOutput(true);
        String data = "grant_type=client_credentials";
        connection.getOutputStream().write(data.getBytes("UTF-8"));

        int responseCode = connection.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            BufferedReader input = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            String response = input.readLine();
            input.close();

            // Parse the response JSON and extract the access token
            JsonObject json = (JsonObject) JsonParser.parseString(response);
            String accessToken = json.get("access_token").getAsString();

            return accessToken;
        } else {
            throw new RuntimeException("Failed to obtain access token. Response code: " + responseCode);
        }
    }
}
