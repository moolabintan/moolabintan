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

public class TVSubPanel extends JPanel {
    private DataViewer parent;

    public TVSubPanel(LayoutManager layout, DataViewer parent) {
        // super(layout);
        this.parent = parent;
        
        String[] informationTypes = { "Default", "Genres"};
        JComboBox<String> informationTypesBox = new JComboBox<String>(informationTypes);

        JLabel informationTypesLabel = new JLabel("TV Show Info: ");
        this.add(informationTypesLabel, BorderLayout.WEST);
        this.add(informationTypesBox, BorderLayout.EAST);

        TVSubPanel tvsp = this;
               
        informationTypesBox.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {
                    if (informationTypesBox.getSelectedItem().equals("Default")) {
                        tvsp.add(parent.addReview, BorderLayout.SOUTH);
                        parent.setTVTable(DataViewer.DEFAULT_ROWS);
                    }
                    if (informationTypesBox.getSelectedItem().equals("Genres")) {
                        tvsp.remove(parent.addReview);
                        tvsp.add(parent.addReview, BorderLayout.SOUTH);
                        setGenresTable(DataViewer.DEFAULT_ROWS);
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

        CallableStatement callstmt = this.parent.database.getConnection().prepareCall("{call get_TV_Genres(?)}");
        callstmt.setInt(1, numRows);
        callstmt.execute();
        ResultSet rs = callstmt.getResultSet();
        int i = 0;
        while (rs.next()) {
            ArrayList<Object> currentRow = new ArrayList<Object>();
            currentRow.add(rs.getString("Name"));
            currentRow.add(rs.getString("Description"));
            currentRow.add(rs.getString("Genre"));
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
