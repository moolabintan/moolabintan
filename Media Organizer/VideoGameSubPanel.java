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

public class VideoGameSubPanel extends JPanel {
    private DataViewer parent;

    public VideoGameSubPanel(LayoutManager layout, DataViewer parent) {
        // super(layout);
        this.parent = parent;
        
        String[] informationTypes = { "Default", "Genres", "Publishers", "Developers"};
        JComboBox<String> informationTypesBox = new JComboBox<String>(informationTypes);

        JLabel informationTypesLabel = new JLabel("Video Game Info: ");
        this.add(informationTypesLabel, BorderLayout.WEST);
        this.add(informationTypesBox, BorderLayout.EAST);

        VideoGameSubPanel vgsp = this;
        JButton addGenre = new JButton("Add genre");

        addGenre.addActionListener(new ActionListener() {

            @Override
            public void actionPerformed(ActionEvent e) {
                JFrame formFrame = new JFrame("Add Genre");
                formFrame.setSize(450, 450);
                formFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
                formFrame.setVisible(true);

                JLabel vg_label = new JLabel("Video Game Name: ");
                JTextField vg_name = new JTextField("", 20);

                JPanel vg_Panel = new JPanel();
                vg_Panel.add(vg_label, BorderLayout.EAST);
                vg_Panel.add(vg_name, BorderLayout.WEST);

                formFrame.add(vg_Panel, BorderLayout.NORTH);

                JLabel genre_label = new JLabel("Video Game Genre: ");
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
                            CallableStatement callstmt = parent.database.getConnection().prepareCall("{call insert_VG_Genre(?, ?)}");
                            callstmt.setString(1, vg_name.getText());
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
                        vgsp.remove(addGenre);
                        vgsp.add(parent.addReview, BorderLayout.SOUTH);
                        vgsp.add(parent.addFilters, BorderLayout.SOUTH);
                        parent.setVideoGameTable(DataViewer.DEFAULT_ROWS);
                    }
                    if (informationTypesBox.getSelectedItem().equals("Genres")) {
                        vgsp.remove(parent.addReview);
                        vgsp.add(addGenre, BorderLayout.SOUTH);
                        setGenresTable(DataViewer.DEFAULT_ROWS);
                    }
                    if (informationTypesBox.getSelectedItem().equals("Publishers")) {
                        vgsp.remove(parent.addReview);
                        vgsp.remove(addGenre);
                        setPublishersTable(DataViewer.DEFAULT_ROWS);
                    }
                    if (informationTypesBox.getSelectedItem().equals("Developers")) {
                        vgsp.remove(parent.addReview);
                        vgsp.remove(addGenre);
                        setDevelopersTable(DataViewer.DEFAULT_ROWS);
                    }
                    parent.frame.setSize(parent.frame.getSize().width + 5, parent.frame.getSize().height);
                    parent.frame.setSize(parent.frame.getSize().width - 5, parent.frame.getSize().height);
                } catch (SQLException e1) {
                    System.out.println(e1.getMessage());
                    e1.printStackTrace();
                }
            }
            
        });
        
        informationTypesBox.setSelectedItem("Default");
    }

    private void setGenresTable(int numRows) throws SQLException {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        Object[] columnNames = { "Name", "Description", "Genre" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.parent.database.getConnection().prepareCall("{call get_VG_Genres(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.parent.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
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

    private void setDevelopersTable(int numRows) throws SQLException {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        Object[] columnNames = { "Name", "Description", "Developer" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.parent.database.getConnection().prepareCall("{call get_VG_Developers(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.parent.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("DeveloperName"));
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

    private void setPublishersTable(int numRows) throws SQLException {
        if (this.parent.tablePane != null) {
            this.parent.frameComponent.remove(this.parent.tablePane);
        }

        Object[] columnNames = { "Name", "Description", "Publisher" };

        ArrayList<ArrayList<Object>> tableList = new ArrayList<ArrayList<Object>>();

        CallableStatement callstmt = this.parent.database.getConnection().prepareCall("{call get_VG_Publishers(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        this.parent.tableIds = new ArrayList<Integer>();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("PublisherName"));
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
