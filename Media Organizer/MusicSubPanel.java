package MediaOrganizerViewers;

import java.awt.BorderLayout;
import java.awt.LayoutManager;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowEvent;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.JScrollPane;

public class MusicSubPanel extends JPanel {
    private DataViewer parent;

    public MusicSubPanel(LayoutManager layout, DataViewer parent) {
        this.parent = parent;

        String[] informationTypes = { "Default", "Genres", "Artist", "Album" };
        JComboBox<String> informationTypesBox = new JComboBox<>(informationTypes);

        JLabel informationTypesLabel = new JLabel("Music Info: ");
        this.add(informationTypesLabel, BorderLayout.WEST);
        this.add(informationTypesBox, BorderLayout.EAST);

        MusicSubPanel msp = this;
        JButton addGenre = new JButton("Add genre");

        addGenre.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                JFrame formFrame = new JFrame("Add Genre");
                formFrame.setSize(450, 450);
                formFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                formFrame.setVisible(true);

                JLabel song_label = new JLabel("Song Name: ");
                JTextField song_name = new JTextField("", 20);

                JPanel song_Panel = new JPanel();
                song_Panel.add(song_label, BorderLayout.EAST);
                song_Panel.add(song_name, BorderLayout.WEST);

                formFrame.add(song_Panel, BorderLayout.NORTH);

                JLabel genre_label = new JLabel("Song Genre: ");
                JTextField genre_text = new JTextField("", 20);

                JPanel genre_Panel = new JPanel();
                genre_Panel.add(genre_label, BorderLayout.EAST);
                genre_Panel.add(genre_text, BorderLayout.WEST);

                formFrame.add(genre_Panel, BorderLayout.CENTER);

                JButton button = new JButton("Done");

                button.addActionListener(new ActionListener() {

                    @Override
                    public void actionPerformed(ActionEvent e) {
                        try {
                            CallableStatement callstmt = parent.database.getConnection().prepareCall("{call insert_Music_Genre(?, ?)}");
                            callstmt.setString(1, song_name.getText());
                            callstmt.setString(2, genre_text.getText());
                            callstmt.execute();
                            if (callstmt.getUpdateCount() < 1) {
                                System.out.println("I have failed");
                            } else {
                                setGenresTable(DataViewer.DEFAULT_ROWS);
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

        informationTypesBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {
                    if (informationTypesBox.getSelectedItem().equals("Default")) {
                        msp.remove(addGenre);
                        msp.add(parent.addReview, BorderLayout.SOUTH);
                        parent.setMusicTable(DataViewer.DEFAULT_ROWS);
                    }
                    if (informationTypesBox.getSelectedItem().equals("Genres")) {
                        msp.remove(parent.addReview);
                        msp.add(addGenre, BorderLayout.SOUTH);
                        setGenresTable(DataViewer.DEFAULT_ROWS);
                    }
                    if (informationTypesBox.getSelectedItem().equals("Artist")) {
                        msp.remove(parent.addReview);
                        msp.remove(addGenre);
                        setArtistsTable(DataViewer.DEFAULT_ROWS);
                    }
                    if (informationTypesBox.getSelectedItem().equals("Album")) {
                        msp.remove(parent.addReview);
                        msp.remove(addGenre);
                        setAlbumTable(DataViewer.DEFAULT_ROWS);
                    }
                    msp.revalidate();
                    msp.repaint();
                } catch (SQLException e1) {
                    e1.printStackTrace();
                }
            }
        });

        this.add(parent.addReview, BorderLayout.SOUTH);

    }

    private void setGenresTable(int numRows) throws SQLException {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        Object[] columnNames = { "Name", "Artist", "Description", "Genre" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.parent.database.getConnection().prepareCall("{call get_Music_Genres(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.parent.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Artist"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("Genre"));
            this.parent.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.parent.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.parent.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.parent.tablePane = new JScrollPane(this.parent.table);
        this.parent.frameComponent.add(this.parent.tablePane, BorderLayout.CENTER);
        this.parent.frameComponent.repaint();
    }

    private void setArtistsTable(int numRows) throws SQLException {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        Object[] columnNames = { "Artist" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.parent.database.getConnection().prepareCall("{call get_music_artist(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.parent.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            this.parent.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.parent.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.parent.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.parent.tablePane = new JScrollPane(this.parent.table);
        this.parent.frameComponent.add(this.parent.tablePane, BorderLayout.CENTER);
        this.parent.frameComponent.repaint();
    }

    private void setAlbumTable(int numRows) throws SQLException {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        Object[] columnNames = { "Name", "Artist" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.parent.database.getConnection().prepareCall("{call get_music_album(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.parent.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Artist_Name"));
            this.parent.tableIds.add(i, rs.getInt("ID"));
            i++;
            tableList.add(currentRow);
        }

        Object[][] tableArray = new Object[tableList.size()][];

        for (i = 0; i < tableArray.length; i++) {
            tableArray[i] = tableList.get(i).toArray();
        }

        this.parent.table = new JTable(tableArray, columnNames) {
            @Override
            public boolean isCellEditable(int row, int column) {
                return false;
            }
        };
        this.parent.table.setAutoResizeMode(JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);

        this.parent.tablePane = new JScrollPane(this.parent.table);
        this.parent.frameComponent.add(this.parent.tablePane, BorderLayout.CENTER);
        this.parent.frameComponent.repaint();
    }

}
