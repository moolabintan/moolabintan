package DatabaseUtilities;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnectionService {

	private final String ConnectionURL = "jdbc:sqlserver://titan.csse.rose-hulman.edu;databaseName=${Server};";

	private Connection connection = null;

	public DatabaseConnectionService() {
        
	}

	public boolean connect(String user, String pass, String server) {
		String connectionURL = ConnectionURL.replace("${Server}", server);
		try {
			connection = DriverManager.getConnection(connectionURL, user, pass);
		} catch (SQLException e) {
			System.out.println(e.getMessage());
			return false;
		}
		return true;
	}
	

	public Connection getConnection() {
		return this.connection;
	}
	
	public void closeConnection() {
		try {
			connection.close();
		} catch (SQLException e) {
			System.out.println(e.getMessage());
		}
	}

}
