package MediaOrganizerViewers;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.KeySpec;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Base64;
import java.util.Random;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPasswordField;
import javax.swing.JTextField;

import DatabaseUtilities.DatabaseConnectionService;

public class LoginViewer extends JFrame {

    DatabaseConnectionService database;
    int UserID;
    JFrame parentFrame;
    static final Random RANDOM = new SecureRandom();
    static final Base64.Encoder enc = Base64.getEncoder();
    static final Base64.Decoder dec = Base64.getDecoder();

    public LoginViewer(DatabaseConnectionService database, JFrame parentFrame) {
        this.database = database;
        this.parentFrame = parentFrame;
        this.setTitle("Login");
        this.setSize(800, 600);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setVisible(true);
        this.addWindowListener(new CloseListener(database));
        this.setLocationRelativeTo(null);
        this.setLayout(null);

        JLabel user = new JLabel("Username:");
        JLabel password = new JLabel("Password:");

        JTextField userText = new JTextField();
        JPasswordField passText = new JPasswordField();

        JButton login = new JButton("Login");
        JButton signUp = new JButton("Sign Up");

        user.setBounds(200, 200, 75, 40);
        password.setBounds(200, 250, 75, 40);
        userText.setBounds(300, 200, 200, 40);
        passText.setBounds(300, 250, 200, 40);
        login.setBounds(500, 200, 100, 40);
        signUp.setBounds(500, 250, 100, 40);

        login.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                login(userText.getText(), new String(passText.getPassword()));
            }
        });

        signUp.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                register(userText.getText(), new String(passText.getPassword()));
            }
        });

        this.add(userText);
        this.add(passText);
        this.add(user);
        this.add(password);
        this.add(login);
        this.add(signUp);

        this.setSize(this.getSize().width + 5, this.getSize().height);
        this.setSize(this.getSize().width - 5, this.getSize().height);
    }

    public boolean login(String username, String password) {
        try {
            String query = "SELECT * \n from  [MediaOrganizer].[dbo].[User]\n  WHERE Username = ?\n";
            PreparedStatement stmt = this.database.getConnection().prepareStatement(query);
            if (username != null) {
                stmt.setString(1, username);
            } else {
                JOptionPane.showMessageDialog(null, "ERROR: Username cannot be null or empty");
                return false;
            }
            ResultSet rs = stmt.executeQuery();
            rs.next();
            UserID = rs.getInt("ID");
            System.out.println("The user that has logged in has userID: " + UserID);
            String existingPassword = rs.getString(4);
            byte[] salt = rs.getBytes(3);
            String newPassword = hashPassword(salt, password);

            if (existingPassword.equals(newPassword)) {
                this.setVisible(false);
                parentFrame.setVisible(true);
                return true;
            } else {
                JOptionPane.showMessageDialog(null, "Login Failed");
                return false;
            }

            // CallableStatement callstmt = this.database.getConnection().prepareCall("{? = call get_User_Salt(?, ?)}");
            // callstmt.registerOutParameter(1, Types.INTEGER);
            // callstmt.registerOutParameter(3, Types.VARCHAR);
            // callstmt.setString(2, username);
            // callstmt.execute();

            // if (callstmt.getInt(1) == 0) {
            //     byte[] salt = callstmt.getBytes(3);
            //     System.out.println("My salt is " + String.valueOf(salt));
            //     String hashedPassword = hashPassword(salt, password);
            //     System.out.println("My password hash is " + hashedPassword);
            //     callstmt = this.database.getConnection().prepareCall("{? = call get_User_Id(?, ?, ?)}");
            //     callstmt.registerOutParameter(1, Types.INTEGER);
            //     callstmt.registerOutParameter(4, Types.INTEGER);
            //     callstmt.setString(2, username);
            //     callstmt.setString(3, hashedPassword);
            //     callstmt.execute();

            //     if (callstmt.getInt(1) == 0) {
            //         UserID = callstmt.getInt(4);
            //         System.out.println("The user that has logged in has userID: " + UserID);
            //         this.setVisible(false);
            //         parentFrame.setVisible(true);
            //         return true;
            //     }
            // }

            // JOptionPane.showMessageDialog(null, "Login Failed");
            // return false;

        } catch (Exception e1) {
            e1.printStackTrace();
        }

        return false;
    }

    public boolean register(String username, String password) {
        try {
            CallableStatement cs = this.database.getConnection().prepareCall("{? = call AddUser(?,?,?)}");

            cs.registerOutParameter(1, Types.INTEGER);
            cs.setString(2, username);
            byte[] salt = getNewSalt();
            cs.setBytes(3, salt);
            cs.setString(4, hashPassword(salt, password));

            cs.execute();
            int returnValue = cs.getInt(1);
            if (returnValue == 1) {
                JOptionPane.showMessageDialog(null, "ERROR: Username cannot be null or empty.");
                return false;
            } else if (returnValue == 2) {
                JOptionPane.showMessageDialog(null, "ERROR: PasswordSalt cannot be null or empty.");
                return false;

            } else if (returnValue == 3) {
                JOptionPane.showMessageDialog(null, "ERROR: PasswordHash cannot be null or empty.");
                return false;

            } else if (returnValue == 4) {
                JOptionPane.showMessageDialog(null, "ERROR: Username already exists.");
                return false;
            } else {
                JOptionPane.showMessageDialog(null, "Added Successfuly");
                System.out.println("Added succesfully");
                this.setVisible(false);
                parentFrame.setVisible(true);
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public byte[] getNewSalt() {
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);
        return salt;
    }

    public String getStringFromBytes(byte[] data) {
        return enc.encodeToString(data);
    }

    public String hashPassword(byte[] salt, String password) {

        KeySpec spec = new PBEKeySpec(password.toCharArray(), salt, 65536, 128);
        SecretKeyFactory f;
        byte[] hash = null;
        try {
            f = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
            hash = f.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException e) {
            JOptionPane.showMessageDialog(null, "An error occurred during password hashing. See stack trace.");
            e.printStackTrace();
        } catch (InvalidKeySpecException e) {
            JOptionPane.showMessageDialog(null, "An error occurred during password hashing. See stack trace.");
            e.printStackTrace();
        }
        return getStringFromBytes(hash);
    }
}
