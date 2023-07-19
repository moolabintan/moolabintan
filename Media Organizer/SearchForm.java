package MediaOrganizerViewers;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.*;
import java.awt.*;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URI;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.awt.BorderLayout;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.SpinnerNumberModel;
import javax.swing.event.TableModelEvent;
import javax.swing.event.TableModelListener;
import java.awt.event.*;

//import SpotifyAuthorizationService;

import DatabaseUtilities.DatabaseConnectionService;

public class SearchForm extends JPanel {
    // GUI components
    private DataViewer parent;
    private  DatabaseConnectionService database;
    private JFrame frame;
    private int currentlySelectedRow;
    private JLabel movieLabel;
    private JTextField movieField;
    private JLabel yearLabel;
    private JTextField yearField;
    private JButton searchButton;
    private JTable resultsTable;
    private JScrollPane scrollPane;

    public SearchForm(LayoutManager layout, DataViewer parent) {
        this.parent = parent;
        this.database = database;

         // Create a JLabel for the search field
        movieLabel = new JLabel("Name:");

        // Create a JTextField for the user to enter their search query
        movieField = new JTextField(10);

        // Create a JLabel for the search field
        yearLabel = new JLabel("Year:");

        // Create a JTextField for the user to enter their search query
        yearField = new JTextField(10);

        // Create a JButton to trigger the search
        searchButton = new JButton("Search");

        String[] mediaTypes = { "Video Game", "Music", "Movies", "TV Shows" };
        JComboBox<String> mediaTypesBox = new JComboBox<String>(mediaTypes);

        searchButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                try {
                    String movie = movieField.getText();
                    movie = movie.replaceAll("\\s", "%20");
                    String year = yearField.getText();
                    if (mediaTypesBox.getSelectedItem().toString().equals("Movies")) {
                        searchMovies(movie);
                    } else if (mediaTypesBox.getSelectedItem().toString().equals("TV Shows")) {
                        searchTV(movie);
                    } /*else if (mediaTypesBox.getSelectedItem().toString().equals("Music")) {
                        searchMusic(movie);
                    }*/
                    parent.frame.setSize(parent.frame.getSize().width + 5, parent.frame.getSize().height);
                    parent.frame.setSize(parent.frame.getSize().width - 5, parent.frame.getSize().height);
                } catch (Exception ne) {
                    ne.printStackTrace();
                    System.out.println(ne.getLocalizedMessage());
                    System.out.println(ne.getMessage());
                }
            }

        });

        // Add an ActionListener to the search button
       

        // Add the search components to the search panel
        this.add(mediaTypesBox);
        this.add(movieLabel);
        this.add(movieField);
        this.add(yearLabel);
        this.add(yearField);
        this.add(searchButton);
        this.add(parent.addReview, BorderLayout.SOUTH);

        // Create a JTable to display the search results
        // resultsTable = new JTable();

        // Create a JScrollPane to wrap the JTable
        // scrollPane = new JScrollPane(resultsTable);

        // Add the search panel and the scroll pane to the JFrame
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }
        this.parent.frame.add(this);
        this.parent.frameComponent.repaint();
        // frame.add(searchPanel, BorderLayout.NORTH);

        // Set the JFrame to be visible
        // frame.setVisible(true);

        parent.frame.setSize(parent.frame.getSize().width + 5, parent.frame.getSize().height);
        parent.frame.setSize(parent.frame.getSize().width - 5, parent.frame.getSize().height);
    }

    public void searchMovies(String movie) throws Exception {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        System.out.println("I am in the search function\n");

        Object[] columnNames = { "Name", "Description", "UserScore" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        // Code below is to populate movies
        // DatabaseConnectionService database = new DatabaseConnectionService();
        // if (database.connect("olabinmo", "Password123") == false)
        // return;

        // currently using a test playlist on my spotify to insert the sample data

        URI uri = new URI(
                "https://api.themoviedb.org/3/search/movie?api_key=6dedcd97745400586f90889421da1197&language=en-US&query="
                        + movie + "&page=1&include_adult=false&region=US");

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
            int pages = 0;
            // JsonObject first = (JsonObject) movies.get(movies.size() - 1);
            // System.out.println("Trying to print something directly from json: " +
            // json.get("total_pages") + "\n");
            pages = json.get("total_pages").getAsInt();

            // if(pages > 10){
            // pages = 10;
            // }
            JOptionPane.showMessageDialog(this.parent.frameComponent, "Loading Movies");

            for (int page = 1; page <= pages; page++) {

                URI innerUri = new URI(
                        "https://api.themoviedb.org/3/search/movie?api_key=6dedcd97745400586f90889421da1197&language=en-US&query="
                                + movie + "&page=" + page + "&include_adult=false&region=US");

                HttpURLConnection innerConnection = (HttpURLConnection) innerUri.toURL().openConnection();
                innerConnection.setRequestMethod("GET");
                int innerResponseCode = innerConnection.getResponseCode();

                if (innerResponseCode == HttpURLConnection.HTTP_OK) {
                    BufferedReader innerInput = new BufferedReader(
                            new InputStreamReader(innerConnection.getInputStream()));
                    JsonObject innerJson = (JsonObject) JsonParser.parseReader(innerInput);
                    // System.out.println(json.toString());
                    innerInput.close();

                    // JsonObject response = (JsonObject) json.get("results");
                    JsonArray innerMovies = (JsonArray) innerJson.get("results");

                    ArrayList<String> movieIds = new ArrayList<String>();
                    for (int j = 0; j < 500 && j < innerMovies.size(); j++) {
                        JsonObject current = (JsonObject) innerMovies.get(j);
                        movieIds.add(current.get("id").getAsString());
                    }

                    System.out.println("Initialized function.");
                    for (int j = 0; j < movieIds.size(); j++) {
                        URI appUri = new URI("https://api.themoviedb.org/3/movie/" + movieIds.get(j)
                                + "?api_key=6dedcd97745400586f90889421da1197");
                        HttpURLConnection appCon = (HttpURLConnection) appUri.toURL().openConnection();
                        appCon.setRequestMethod("GET");
                        int appResponseCode = appCon.getResponseCode();
                        if (appResponseCode == HttpURLConnection.HTTP_OK) {
                            BufferedReader appIn = new BufferedReader(new InputStreamReader(appCon.getInputStream()));
                            JsonObject appJson = (JsonObject) JsonParser.parseReader(appIn);
                            appIn.close();

                            ArrayList<Object> currentRow = new ArrayList<Object>();
                            currentRow.add(appJson.get("title").getAsString());
                            currentRow.add(appJson.get("overview").getAsString());
                            currentRow.add(appJson.get("vote_average").getAsString());
                            tableList.add(currentRow);
                        }
                    }

                }

            }

        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (int i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.parent.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        // parent.addReview.addActionListener(new ActionListener() {

        //     @Override
        //     public void actionPerformed(ActionEvent e) {
        //         JFrame formFrame = new JFrame("Add Review");
        //         formFrame.setSize(450, 450);
        //         formFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        //         formFrame.setVisible(true);

        //         JLabel nameLabel = new JLabel("Media Name: " +  parent.table.getValueAt(currentlySelectedRow, 0));

        //         JPanel namePanel = new JPanel();
        //         namePanel.add(nameLabel, BorderLayout.CENTER);

        //         formFrame.add(namePanel, BorderLayout.NORTH);

        //         JLabel reviewLabel = new JLabel("Review: ");
        //         JTextArea reviewText = new JTextArea(5, 20);
        //         reviewText.setWrapStyleWord(true);
        //         reviewText.setLineWrap(true);

        //         JPanel reviewPanel = new JPanel();
        //         reviewPanel.add(reviewLabel, BorderLayout.WEST);
        //         reviewPanel.add(reviewText, BorderLayout.EAST);

        //         JLabel scoreLabel = new JLabel("Select a score from 0 to 100: ");
        //         JSpinner scoreSpinner = new JSpinner(new SpinnerNumberModel(100, 0, 100, 1));

        //         JPanel scorePanel = new JPanel();
        //         scorePanel.add(scoreLabel, BorderLayout.WEST);
        //         scorePanel.add(scoreSpinner, BorderLayout.EAST);

        //         JPanel centerPanel = new JPanel(new BorderLayout());
        //         centerPanel.add(reviewPanel, BorderLayout.NORTH);
        //         centerPanel.add(scorePanel, BorderLayout.CENTER);

        //         formFrame.add(centerPanel, BorderLayout.CENTER);

        //         JButton button = new JButton("Done");

        //         button.addActionListener(new ActionListener() {

        //             @Override
        //             public void actionPerformed(ActionEvent e) {
        //                 try {
        //                     CallableStatement callstmt = database.getConnection().prepareCall("{? = call insert_User_Review(?, ?, ?, ?)}");
        //                     callstmt.registerOutParameter(1, Types.INTEGER);
        //                     callstmt.setInt(2, loginViewer.UserID);
        //                     callstmt.setInt(3, tableIds.get(currentlySelectedRow));
        //                     callstmt.setInt(4, (Integer) scoreSpinner.getValue());
        //                     callstmt.setString(5, reviewText.getText());
        //                     callstmt.execute();
        //                     int ret = callstmt.getInt(1);
        //                     if (ret != 0) {
        //                         System.out.println("I have failed");
        //                         JDialog errorDialog = new JDialog(formFrame, "Error: Update failed");
        //                         errorDialog.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        //                         JButton ok = new JButton("Ok");
        //                         errorDialog.add(ok);
        //                         ok.addActionListener(new ActionListener() {

        //                             @Override
        //                             public void actionPerformed(ActionEvent e) {
        //                                 errorDialog.dispatchEvent(
        //                                         new WindowEvent(errorDialog, WindowEvent.WINDOW_CLOSING));
        //                             }

        //                         });
        //                     } else {
        //                         formFrame.dispatchEvent(new WindowEvent(formFrame, WindowEvent.WINDOW_CLOSING));
        //                     }
        //                 } catch (SQLException e1) {
        //                     e1.printStackTrace();
        //                 }
        //             }

        //         });

        //         formFrame.add(button, BorderLayout.SOUTH);
        //     }
        // }

        // );

        this.parent.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    parent.addReview.setEnabled(true);
                } else {
                    parent.addReview.setEnabled(false);
                }
            }

            @Override
            public void mousePressed(MouseEvent e) {
            }

            @Override
            public void mouseReleased(MouseEvent e) {
            }

            @Override
            public void mouseEntered(MouseEvent e) {
            }

            @Override
            public void mouseExited(MouseEvent e) {
            }

        });

        this.parent.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.parent.tablePane = new JScrollPane(this.parent.table);
        this.parent.frameComponent.add(this.parent.tablePane, BorderLayout.CENTER);
        this.parent.frameComponent.repaint();

        // database.closeConnection();

        JOptionPane.showMessageDialog(this.parent.frameComponent, "Finished Loading Movies");
    }

    public void searchTV(String tvshow) throws Exception {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        System.out.println("I am in the search function\n");

        Object[] columnNames = { "Name", "Description", "UserScore" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        // Code below is to populate movies
        // DatabaseConnectionService database = new DatabaseConnectionService();
        // if (database.connect("olabinmo", "Password123") == false)
        // return;

        // currently using a test playlist on my spotify to insert the sample data

        URI uri = new URI(
                "https://api.themoviedb.org/3/search/tv?api_key=6dedcd97745400586f90889421da1197&language=en-US&query="
                        + tvshow + "&page=1&include_adult=false&region=US");

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
            int pages = 0;
            // JsonObject first = (JsonObject) movies.get(movies.size() - 1);
            // System.out.println("Trying to print something directly from json: " +
            // json.get("total_pages") + "\n");
            pages = json.get("total_pages").getAsInt();

            // if(pages > 10){
            // pages = 10;
            // }
            JOptionPane.showMessageDialog(this.parent.frameComponent, "Loading TV Shows");

            for (int page = 1; page <= pages; page++) {

                URI innerUri = new URI(
                        "https://api.themoviedb.org/3/search/tv?api_key=6dedcd97745400586f90889421da1197&language=en-US&query="
                                + tvshow + "&page=" + page + "&include_adult=false&region=US");

                HttpURLConnection innerConnection = (HttpURLConnection) innerUri.toURL().openConnection();
                innerConnection.setRequestMethod("GET");
                int innerResponseCode = innerConnection.getResponseCode();

                if (innerResponseCode == HttpURLConnection.HTTP_OK) {
                    BufferedReader innerInput = new BufferedReader(
                            new InputStreamReader(innerConnection.getInputStream()));
                    JsonObject innerJson = (JsonObject) JsonParser.parseReader(innerInput);
                    // System.out.println(json.toString());
                    innerInput.close();

                    // JsonObject response = (JsonObject) json.get("results");
                    JsonArray innerMovies = (JsonArray) innerJson.get("results");

                    ArrayList<String> movieIds = new ArrayList<String>();
                    for (int j = 0; j < 500 && j < innerMovies.size(); j++) {
                        JsonObject current = (JsonObject) innerMovies.get(j);
                        movieIds.add(current.get("id").getAsString());
                    }

                    System.out.println("Initialized function.");
                    for (int j = 0; j < movieIds.size(); j++) {
                        URI appUri = new URI("https://api.themoviedb.org/3/tv/" + movieIds.get(j)
                                + "?api_key=6dedcd97745400586f90889421da1197");
                        HttpURLConnection appCon = (HttpURLConnection) appUri.toURL().openConnection();
                        appCon.setRequestMethod("GET");
                        int appResponseCode = appCon.getResponseCode();
                        if (appResponseCode == HttpURLConnection.HTTP_OK) {
                            BufferedReader appIn = new BufferedReader(new InputStreamReader(appCon.getInputStream()));
                            JsonObject appJson = (JsonObject) JsonParser.parseReader(appIn);
                            appIn.close();

                            ArrayList<Object> currentRow = new ArrayList<Object>();
                            currentRow.add(appJson.get("name").getAsString());
                            currentRow.add(appJson.get("overview").getAsString());
                            currentRow.add(appJson.get("vote_average").getAsString());
                            tableList.add(currentRow);
                        }
                    }

                }

            }

        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (int i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.parent.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        this.parent.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        this.parent.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    parent.addReview.setEnabled(true);
                } else {
                    parent.addReview.setEnabled(false);
                }
            }

            @Override
            public void mousePressed(MouseEvent e) {
            }

            @Override
            public void mouseReleased(MouseEvent e) {
            }

            @Override
            public void mouseEntered(MouseEvent e) {
            }

            @Override
            public void mouseExited(MouseEvent e) {
            }

        });


        this.parent.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.parent.tablePane = new JScrollPane(this.parent.table);
        this.parent.frameComponent.add(this.parent.tablePane, BorderLayout.CENTER);
        this.parent.frameComponent.repaint();

        // database.closeConnection();

        JOptionPane.showMessageDialog(this.parent.frameComponent, "Finished Loading Movies");
    }
    /*
    public void searchMusic(String term) throws Exception {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }
    
        System.out.println("I am in the search function\n");
    
        Object[] columnNames = { "Name", "Artist", "Album", "Description", "UserScore" };
    
        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();
    
        // Obtain the access token from SpotifyAuthorizationService
        String accessToken = SpotifyAuthorizationService.getAccessToken();
    
        // Construct the search API endpoint URL
        String searchUrl = "https://api.spotify.com/v1/search?q=" + term + "&type=track&limit=50";
    
        // Create a connection to the Spotify API
        HttpURLConnection connection = (HttpURLConnection) new URL(searchUrl).openConnection();
        connection.setRequestMethod("GET");
        connection.setRequestProperty("Authorization", "Bearer " + accessToken);
    
        int responseCode = connection.getResponseCode();
    
        if (responseCode == HttpURLConnection.HTTP_OK) {
            BufferedReader input = new BufferedReader(new InputStreamReader(connection.getInputStream()));
            JsonObject json = (JsonObject) JsonParser.parseReader(input);
            input.close();
    
            JsonArray tracks = (JsonArray) json.get("tracks").getAsJsonObject().get("items");
    
            for (int i = 0; i < tracks.size(); i++) {
                JsonObject track = (JsonObject) tracks.get(i);
                JsonObject album = (JsonObject) track.get("album");
                JsonArray artists = (JsonArray) track.get("artists");
    
                String name = track.get("name").getAsString();
                String artist = artists.get(0).getAsJsonObject().get("name").getAsString();
                String albumName = album.get("name").getAsString();
                String description = track.get("popularity").getAsString();
                int userScore = track.get("popularity").getAsInt();
    
                // Check if any of the fields match the search term
                if (name.toLowerCase().contains(term.toLowerCase()) || artist.toLowerCase().contains(term.toLowerCase()) ||
                    albumName.toLowerCase().contains(term.toLowerCase())) {
    
                    ArrayList<Object> currentRow = new ArrayList<Object>();
                    currentRow.add(name);
                    currentRow.add(artist);
                    currentRow.add(albumName);
                    currentRow.add(description);
                    currentRow.add(userScore);
                    tableList.add(currentRow);
                }
    
                // Limit the number of rows to 50
                if (tableList.size() >= 50) {
                    break;
                }
            }
        }
    
        Object[][] tableArray = new Object[tableList.size()][];
        for (int i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }
    
        this.parent.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
    
        this.parent.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    parent.addReview.setEnabled(true);
                } else {
                    parent.addReview.setEnabled(false);
                }
            }

            @Override
            public void mousePressed(MouseEvent e) {
            }

            @Override
            public void mouseReleased(MouseEvent e) {
            }

            @Override
            public void mouseEntered(MouseEvent e) {
            }

            @Override
            public void mouseExited(MouseEvent e) {
            }

        });


        this.parent.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.parent.tablePane = new JScrollPane(this.parent.table);
        this.parent.frameComponent.add(this.parent.tablePane, BorderLayout.CENTER);
        this.parent.frameComponent.repaint();
    
        JOptionPane.showMessageDialog(this.parent.frameComponent, "Finished Loading Songs");
    }
    */
    
    

    // @Override
    // public void actionPerformed(ActionEvent e) {

    // try {
    // search(searchField.getText());
    // } catch (Exception ne) {
    // ne.printStackTrace();
    // System.out.println(ne.getLocalizedMessage());
    // System.out.println(ne.getMessage());
    // }

    // // // Get the user's search query
    // // String query = searchField.getText();

    // // // TODO: Perform the search and populate the JTable with the results
    // // // For this sample code, we will just display a message dialog with the
    // // search
    // // // query
    // // JOptionPane.showMessageDialog(this, "You searched for: " + query);
    // }

}
