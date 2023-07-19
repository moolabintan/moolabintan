package MediaOrganizerViewers;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SpinnerNumberModel;
import javax.swing.border.Border;

import java.awt.event.*;

import DatabaseUtilities.DatabaseConnectionService;

public class DataViewer {

    static int DEFAULT_ROWS = 100;
    DatabaseConnectionService database;
    JPanel frameComponent;
    JPanel headerComponent;
    JPanel formsComponent;
    JPanel mediaComponent;
    JTable table;
    ArrayList<Integer> tableIds;
    JScrollPane tablePane;
    JFrame frame;
    LoginViewer loginViewer;
    int currentlySelectedRow;
    JComboBox<String> formsBox;
    JButton addReview;
    JButton addFilters;

    String mediaNameFilter = "";
    int userScoreFilter = 0;
    String descriptionFilter = "";
    String ageRatingFilter = "";

    public DataViewer() {
        this.database = new DatabaseConnectionService();
        database.connect("ApplicationProfile", "Password1234$", "MediaOrganizer");

        this.frame = new JFrame("Media Organizer");

        loginViewer = new LoginViewer(database, frame);

        this.frame.setSize(450, 450);
        this.frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.frame.setVisible(false);
        this.frame.addWindowListener(new CloseListener(database));
        this.frameComponent = new JPanel(new BorderLayout());
        this.frame.add(this.frameComponent);

        String[] mediaTypes = { "Video Game", "Music", "Movies", "TV Shows" };

        this.formsComponent = new JPanel();

        String[] forms = { "Media", "Search", "Reviews", "Profile" };
        formsBox = new JComboBox<String>(forms);

        this.formsComponent.add(formsBox, BorderLayout.CENTER);

        JComboBox<String> mediaTypesBox = new JComboBox<String>(mediaTypes);

        JLabel mediaTypesLabel = new JLabel("Select a media type: ");

        this.mediaComponent = new JPanel();

        this.mediaComponent.add(formsBox, BorderLayout.CENTER);
        this.mediaComponent.add(mediaTypesLabel, BorderLayout.WEST);
        this.mediaComponent.add(mediaTypesBox, BorderLayout.EAST);

        this.headerComponent = new JPanel(new BorderLayout());
        this.headerComponent.add(mediaComponent, BorderLayout.NORTH);

        this.frameComponent.add(this.headerComponent, BorderLayout.NORTH);

        DataViewer dataViewer = this;

        this.addReview = new JButton("Add review");

        this.addReview.setEnabled(false);

        this.addReview.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                JFrame formFrame = new JFrame("Add Review");
                formFrame.setSize(450, 450);
                formFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                formFrame.setVisible(true);

                JLabel nameLabel = new JLabel("Media Name: " + table.getValueAt(currentlySelectedRow, 0));

                JPanel namePanel = new JPanel();
                namePanel.add(nameLabel, BorderLayout.CENTER);

                formFrame.add(namePanel, BorderLayout.NORTH);

                JLabel reviewLabel = new JLabel("Review: ");
                JTextArea reviewText = new JTextArea(5, 20);
                reviewText.setWrapStyleWord(true);
                reviewText.setLineWrap(true);

                JPanel reviewPanel = new JPanel();
                reviewPanel.add(reviewLabel, BorderLayout.WEST);
                reviewPanel.add(reviewText, BorderLayout.EAST);

                JLabel scoreLabel = new JLabel("Select a score from 0 to 100: ");
                JSpinner scoreSpinner = new JSpinner(new SpinnerNumberModel(100, 0, 100, 1));

                JPanel scorePanel = new JPanel();
                scorePanel.add(scoreLabel, BorderLayout.WEST);
                scorePanel.add(scoreSpinner, BorderLayout.EAST);

                JPanel centerPanel = new JPanel(new BorderLayout());
                centerPanel.add(reviewPanel, BorderLayout.NORTH);
                centerPanel.add(scorePanel, BorderLayout.CENTER);

                formFrame.add(centerPanel, BorderLayout.CENTER);

                JButton button = new JButton("Done");

                button.addActionListener(new ActionListener() {

                    @Override
                    public void actionPerformed(ActionEvent e) {
                        try {
                            CallableStatement callstmt = database.getConnection().prepareCall("{? = call insert_User_Review(?, ?, ?, ?)}");
                            callstmt.registerOutParameter(1, Types.INTEGER);
                            callstmt.setInt(2, loginViewer.UserID);
                            callstmt.setInt(3, tableIds.get(currentlySelectedRow));
                            callstmt.setInt(4, (Integer) scoreSpinner.getValue());
                            callstmt.setString(5, reviewText.getText());
                            callstmt.execute();
                            int ret = callstmt.getInt(1);
                            if (ret != 0) {
                                System.out.println("I have failed");
                                JDialog errorDialog = new JDialog(formFrame, "Error: Update failed");
                                errorDialog.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                                JButton ok = new JButton("Ok");
                                errorDialog.add(ok);
                                ok.addActionListener(new ActionListener() {

                                    @Override
                                    public void actionPerformed(ActionEvent e) {
                                        errorDialog.dispatchEvent(
                                                new WindowEvent(errorDialog, WindowEvent.WINDOW_CLOSING));
                                    }

                                });
                            } else {
                                formFrame.dispatchEvent(new WindowEvent(formFrame, WindowEvent.WINDOW_CLOSING));
                            }
                        } catch (SQLException e1) {
                            e1.printStackTrace();
                        }
                    }

                });

                formFrame.add(button, BorderLayout.SOUTH);
            }
        }

        );

        this.addFilters = new JButton("Add filters");

        this.addFilters.setEnabled(true);

        this.addFilters.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                JFrame formFrame = new JFrame("Add Review");
                formFrame.setSize(450, 450);
                formFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                formFrame.setVisible(true);

                JLabel nameLabel = new JLabel("Name keyword: ");
                JLabel scoreLabel = new JLabel("Minimum score: ");
                JLabel descriptionLabel = new JLabel("Description keyword: ");
                JLabel ageRatingLabel = new JLabel("Age Rating Keyword: ");

                JTextField nameText = new JTextField(mediaNameFilter, 20);
                JSpinner scoreSpinner = new JSpinner(new SpinnerNumberModel(userScoreFilter, 0, 100, 1));
                JTextField descriptionText = new JTextField(descriptionFilter, 20);
                JTextField ageRatingText = new JTextField(ageRatingFilter, 20);

                JPanel namePanel = new JPanel();
                JPanel scorePanel = new JPanel();
                JPanel descriptionPanel = new JPanel();
                JPanel ageRatingPanel = new JPanel();

                namePanel.add(nameLabel, BorderLayout.WEST);
                namePanel.add(nameText, BorderLayout.EAST);

                scorePanel.add(scoreLabel, BorderLayout.WEST);
                scorePanel.add(scoreSpinner, BorderLayout.EAST);

                descriptionPanel.add(descriptionLabel, BorderLayout.WEST);
                descriptionPanel.add(descriptionText, BorderLayout.EAST);

                ageRatingPanel.add(ageRatingLabel, BorderLayout.WEST);
                ageRatingPanel.add(ageRatingText, BorderLayout.EAST);

                JPanel filtersPanel = new JPanel(new BorderLayout());

                filtersPanel.add(namePanel, BorderLayout.NORTH);
                filtersPanel.add(scorePanel, BorderLayout.CENTER);
                filtersPanel.add(descriptionPanel, BorderLayout.SOUTH);
                formFrame.add(ageRatingPanel, BorderLayout.CENTER);

                JButton doneButton = new JButton("Done");
                doneButton.setVisible(true);

                formFrame.add(filtersPanel, BorderLayout.NORTH);
                formFrame.add(doneButton, BorderLayout.SOUTH);

                doneButton.addActionListener(new ActionListener() {

                    @Override
                    public void actionPerformed(ActionEvent e) {
                        mediaNameFilter = nameText.getText();
                        userScoreFilter = (Integer) scoreSpinner.getValue();
                        descriptionFilter = descriptionText.getText();
                        ageRatingFilter = ageRatingText.getText();
                        mediaTypesBox.setSelectedItem(mediaTypesBox.getSelectedItem());
                        formFrame.dispatchEvent(new WindowEvent(formFrame, WindowEvent.WINDOW_CLOSING));
                    }
                    
                });
            }
            
        });

        mediaTypesBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {
                    if (mediaTypesBox.getSelectedItem().equals("Video Game")) {
                        headerComponent.removeAll();
                        headerComponent.add(mediaComponent, BorderLayout.NORTH);
                        headerComponent.add(new VideoGameSubPanel(new BorderLayout(), dataViewer), BorderLayout.SOUTH);
                        frameComponent.add(headerComponent, BorderLayout.NORTH);
                        setVideoGameTable(DEFAULT_ROWS);
                    } if (mediaTypesBox.getSelectedItem().equals("Music")) {
                        /*
                        System.out.println("I'm switching to music tables");
                        headerComponent.removeAll();
                        headerComponent.add(mediaComponent);
                        setMusicTable(DEFAULT_ROWS);
                        */
                        System.out.println("I'm switching to music tables");
                        headerComponent.removeAll();
                        headerComponent.add(mediaComponent, BorderLayout.NORTH);
                        headerComponent.add(new MusicSubPanel(new BorderLayout(), dataViewer), BorderLayout.SOUTH);
                        frameComponent.add(headerComponent, BorderLayout.NORTH);
                        setMusicTable(DEFAULT_ROWS);
                    }
                    if (mediaTypesBox.getSelectedItem().equals("Movies")) {
                        System.out.println("I'm switching to movie tables");
                        headerComponent.removeAll();
                        headerComponent.add(mediaComponent, BorderLayout.NORTH);
                        headerComponent.add(new MoviesSubPanel(new BorderLayout(), dataViewer), BorderLayout.SOUTH);
                        frameComponent.add(headerComponent, BorderLayout.NORTH);
                        setMovieTable(DEFAULT_ROWS);
                    }
                    if (mediaTypesBox.getSelectedItem().equals("TV Shows")) {
                        System.out.println("I'm switching to tv shows tables");
                        headerComponent.removeAll();
                        headerComponent.add(mediaComponent, BorderLayout.NORTH);
                        headerComponent.add(new TVSubPanel(new BorderLayout(), dataViewer), BorderLayout.SOUTH);
                        frameComponent.add(headerComponent, BorderLayout.NORTH);
                        setTVTable(DEFAULT_ROWS);
                    }
                    frame.setSize(frame.getSize().width + 5, frame.getSize().height);
                    frame.setSize(frame.getSize().width - 5, frame.getSize().height);
                } catch (SQLException e1) {
                    System.out.println(e1.getMessage());
                    e1.printStackTrace();
                }
            }

        });

        formsBox.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                if (formsBox.getSelectedItem().equals("Media")) {
                    mediaTypesLabel.setVisible(true);
                    mediaTypesBox.setVisible(true);
                    mediaTypesBox.setSelectedItem("Video Game");
                }
                if (formsBox.getSelectedItem().equals("Search")) {
                    headerComponent.removeAll();
                    mediaTypesBox.setVisible(false);
                    mediaTypesLabel.setVisible(false);
                    headerComponent.add(mediaComponent, BorderLayout.NORTH);
                    headerComponent.add(new SearchForm(new BorderLayout(), dataViewer), BorderLayout.SOUTH);
                    frameComponent.add(headerComponent, BorderLayout.NORTH);
                }
                if (formsBox.getSelectedItem().equals("Profile")) {
                    headerComponent.removeAll();
                    headerComponent.add(mediaComponent);
                    mediaTypesBox.setVisible(false);
                    mediaTypesLabel.setVisible(false);
                    try {
                        setProfileReviewsTable(DEFAULT_ROWS);
                    } catch (SQLException e1) {
                        e1.printStackTrace();
                    }
                }
                if (formsBox.getSelectedItem().equals("Reviews")) {
                    headerComponent.removeAll();
                    headerComponent.add(mediaComponent);
                    mediaTypesBox.setVisible(false);
                    mediaTypesLabel.setVisible(false);
                    try {
                        setReviewsTable(DEFAULT_ROWS);
                    } catch (SQLException e1) {
                        e1.printStackTrace();
                    }
                }
                frame.setSize(frame.getSize().width + 5, frame.getSize().height);
                frame.setSize(frame.getSize().width - 5, frame.getSize().height);
            }

        });

        mediaTypesBox.setSelectedItem("Video Game");
    }


    public void setVideoGameTable(int numRows) throws SQLException {
        if (this.tablePane != null) {
            this.frameComponent.remove(this.tablePane);
        }

        Object[] columnNames = { "Name", "Description", "AgeRating", "UserScore" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.database.getConnection().prepareCall("{call get_VideoGames(?, ?, ?, ?, ?)}");
        callstmt.setInt(1, numRows);
        callstmt.setString(2, this.mediaNameFilter);
        callstmt.setInt(3, this.userScoreFilter);
        callstmt.setString(4, this.descriptionFilter);
        callstmt.setString(5, this.ageRatingFilter);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("AgeRating"));
            currentRow.add(rs.getString("UserScore"));
            this.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    addReview.setEnabled(true);
                } else {
                    addReview.setEnabled(false);
                }
                if (e.getClickCount() == 2) {
                    System.out.println("I double clicked.");
                    JDialog fullText = new JDialog(frame, "Full text for " + table.getColumnName(table.getSelectedColumn()));
                    fullText.setSize(250, 250);
                    fullText.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                    JTextArea descriptionText = new JTextArea((String) table.getValueAt(table.getSelectedRow(), table.getSelectedColumn()));
                    descriptionText.setLineWrap(true);
                    descriptionText.setWrapStyleWord(true);
                    fullText.add(descriptionText, BorderLayout.NORTH);
                    JButton done = new JButton("Done");
                    done.addActionListener(new ActionListener() {

                        @Override
                        public void actionPerformed(ActionEvent e) {
                            fullText.dispatchEvent(new WindowEvent(fullText, WindowEvent.WINDOW_CLOSING));
                        }
                        
                    });
                    fullText.add(done, BorderLayout.SOUTH);
                    fullText.setVisible(true);
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

        this.tablePane = new JScrollPane(this.table);
        this.frameComponent.add(this.tablePane, BorderLayout.CENTER);
        this.frameComponent.repaint();
    }

    public void setMusicTable(int numRows) throws SQLException {
        if (this.tablePane != null) {
            System.out.println("Removing the old table pane");
            this.frameComponent.remove(this.tablePane);
        }
        
        Object[] columnNames = { "Name", "Artist", "Album", "Description", "AgeRating", "UserScore" };
        
        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callStmt = this.database.getConnection().prepareCall("{call get_songs(?)}");
        callStmt.setInt(1, numRows);
        callStmt.execute();
        ResultSet rs = callStmt.getResultSet();
        this.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<>();
            currentRow.add(rs.getString("SongTitle"));
            currentRow.add(rs.getString("ArtistName"));
            currentRow.add(rs.getString("AlbumName"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("AgeRating"));
            currentRow.add(rs.getString("UserScore"));
            this.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        this.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    addReview.setEnabled(true);
                } else {
                    addReview.setEnabled(false);
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

        this.tablePane = new JScrollPane(this.table);
        this.frameComponent.add(this.tablePane, BorderLayout.CENTER);
        this.frameComponent.repaint();
    }

    public void setMovieTable(int numRows) throws SQLException {
        if (this.tablePane != null) {
            this.frameComponent.remove(this.tablePane);
        }

        Object[] columnNames = { "Name", "Description", "UserScore" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.database.getConnection().prepareCall("{call get_TVMovie(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("UserScore"));
            this.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        this.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    addReview.setEnabled(true);
                } else {
                    addReview.setEnabled(false);
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

        this.tablePane = new JScrollPane(this.table);
        this.frameComponent.add(this.tablePane, BorderLayout.CENTER);
        this.frameComponent.repaint();
    }

    public void setTVTable(int numRows) throws SQLException {
        if (this.tablePane != null) {
            this.frameComponent.remove(this.tablePane);
        }

        Object[] columnNames = { "Name", "Description", "UserScore" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.database.getConnection().prepareCall("{call get_TVMovies(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("UserScore"));
            this.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };

        this.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    addReview.setEnabled(true);
                } else {
                    addReview.setEnabled(false);
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

        this.tablePane = new JScrollPane(this.table);
        this.frameComponent.add(this.tablePane, BorderLayout.CENTER);
        this.frameComponent.repaint();
    }


    public void setProfileReviewsTable(int rows) throws SQLException {
        if (this.tablePane != null) {
            this.frameComponent.remove(this.tablePane);
        }

        Object[] columnNames = { "Media Type", "Name", "Review", "Score" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.database.getConnection().prepareCall("{call get_User_Reviews(?)}");
        callstmt.setInt(1, loginViewer.UserID);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Media Type"));
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Review"));
            currentRow.add(rs.getString("Score"));
            this.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        JButton updateReview = new JButton("Update Review");

        this.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.table.addMouseListener(new MouseListener() {

            @Override
            public void mouseClicked(MouseEvent e) {
                JTable source = (JTable) e.getSource();
                currentlySelectedRow = source.getSelectedRow();
                if (currentlySelectedRow != -1) {
                    updateReview.setEnabled(true);
                } else {
                    updateReview.setEnabled(false);
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

        updateReview.setEnabled(false);

        this.headerComponent.add(updateReview, BorderLayout.SOUTH);

        DataViewer parent = this;

        updateReview.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                JFrame formFrame = new JFrame("Update Review");
                formFrame.setSize(450, 450);
                formFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                formFrame.setVisible(true);

                JLabel nameLabel = new JLabel("Media Name: " + table.getValueAt(currentlySelectedRow, 1));

                JPanel namePanel = new JPanel();
                namePanel.add(nameLabel, BorderLayout.CENTER);

                formFrame.add(namePanel, BorderLayout.NORTH);

                JLabel reviewLabel = new JLabel("Review: ");
                JTextArea reviewText = new JTextArea(5, 20);
                reviewText.setWrapStyleWord(true);
                reviewText.setLineWrap(true);

                JPanel reviewPanel = new JPanel();
                reviewPanel.add(reviewLabel, BorderLayout.WEST);
                reviewPanel.add(reviewText, BorderLayout.EAST);

                JLabel scoreLabel = new JLabel("Select a score from 0 to 100: ");
                JSpinner scoreSpinner = new JSpinner(new SpinnerNumberModel(100, 0, 100, 1));

                JPanel scorePanel = new JPanel();
                scorePanel.add(scoreLabel, BorderLayout.WEST);
                scorePanel.add(scoreSpinner, BorderLayout.EAST);

                JPanel centerPanel = new JPanel(new BorderLayout());
                centerPanel.add(reviewPanel, BorderLayout.NORTH);
                centerPanel.add(scorePanel, BorderLayout.CENTER);

                formFrame.add(centerPanel, BorderLayout.CENTER);

                JButton button = new JButton("Done");

                button.addActionListener(new ActionListener() {

                    @Override
                    public void actionPerformed(ActionEvent e) {
                        try {
                            CallableStatement callstmt = database.getConnection().prepareCall("{? = call insert_User_Review(?, ?, ?, ?)}");
                            callstmt.registerOutParameter(1, Types.INTEGER);
                            callstmt.setInt(2, loginViewer.UserID);
                            callstmt.setInt(3, tableIds.get(currentlySelectedRow));
                            callstmt.setInt(4, (Integer) scoreSpinner.getValue());
                            callstmt.setString(5, reviewText.getText());
                            callstmt.execute();
                            int ret = callstmt.getInt(1);
                            if (ret != 0) {
                                System.out.println("I have failed");
                                JDialog errorDialog = new JDialog(formFrame, "Error: Update failed");
                                errorDialog.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                                JButton ok = new JButton("Ok");
                                errorDialog.add(ok);
                                ok.addActionListener(new ActionListener() {

                                    @Override
                                    public void actionPerformed(ActionEvent e) {
                                        errorDialog.dispatchEvent(
                                                new WindowEvent(errorDialog, WindowEvent.WINDOW_CLOSING));
                                    }

                                });
                            } else {
                                parent.formsBox.setSelectedItem("Profile");
                                formFrame.dispatchEvent(new WindowEvent(formFrame, WindowEvent.WINDOW_CLOSING));
                            }
                        } catch (SQLException e1) {
                            e1.printStackTrace();
                        }
                    }

                });

                formFrame.add(button, BorderLayout.SOUTH);
            }

        });

        this.tablePane = new JScrollPane(this.table);
        this.frameComponent.add(this.tablePane, BorderLayout.CENTER);
    }

    public void setReviewsTable(int rows) throws SQLException {
        if (this.tablePane != null) {
            this.frameComponent.remove(this.tablePane);
        }

        Object[] columnNames = { "Media Type", "Name", "Review", "Score" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.database.getConnection().prepareCall("{call get_All_Reviews()}");
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Media Type"));
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Review"));
            currentRow.add(rs.getString("Score"));
            this.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.tablePane = new JScrollPane(this.table);
        this.frameComponent.add(this.tablePane, BorderLayout.CENTER);
    }

    public static void main(String[] args) {
        new DataViewer();
    }
}
