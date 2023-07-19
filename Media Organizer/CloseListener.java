package MediaOrganizerViewers;

import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

import DatabaseUtilities.DatabaseConnectionService;

public class CloseListener implements WindowListener {

    private DatabaseConnectionService database;

    public CloseListener(DatabaseConnectionService database) {
        this.database = database;
    }

    @Override
    public void windowOpened(WindowEvent e) {
    }

    @Override
    public void windowClosing(WindowEvent e) {
        if (this.database.getConnection() != null) this.database.closeConnection();
    }

    @Override
    public void windowClosed(WindowEvent e) {
    }

    @Override
    public void windowIconified(WindowEvent e) {
    }

    @Override
    public void windowDeiconified(WindowEvent e) {
    }

    @Override
    public void windowActivated(WindowEvent e) {
    }

    @Override
    public void windowDeactivated(WindowEvent e) {
    }
    
}
