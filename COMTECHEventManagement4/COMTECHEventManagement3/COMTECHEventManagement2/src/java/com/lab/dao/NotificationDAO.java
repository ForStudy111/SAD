/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.lab.dao;

/**
 *
 * @author wpy92
 */
import com.lab.model.Notification;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    // 1. Standard: Send to a specific person
    public void addNotification(String recipientID, String subject, String messageBody) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO notification (recipientID, subject, messageBody, sendDate) VALUES (?, ?, ?, NOW())";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, recipientID);
            ps.setString(2, subject);
            ps.setString(3, messageBody);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 2. Broadcast: Send to ALL users in the database
    public void broadcastToAll(String subject, String messageBody) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO notification (recipientID, subject, messageBody, sendDate) SELECT userID, ?, ?, NOW() FROM users";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subject);
            ps.setString(2, messageBody);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 3. Notify Role: Send to everyone with a specific role (e.g., ADVISOR)
    public void notifyRole(String role, String subject, String messageBody) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO notification (recipientID, subject, messageBody, sendDate) SELECT userID, ?, ?, NOW() FROM users WHERE role = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subject);
            ps.setString(2, messageBody);
            ps.setString(3, role);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 4. Notify Event Creator: Finds the committee member who proposed the event and notifies them
    public void notifyEventCreator(int eventId, String subject, String messageBody) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO notification (recipientID, subject, messageBody, sendDate) SELECT committeeID, ?, ?, NOW() FROM club_event WHERE eventID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subject);
            ps.setString(2, messageBody);
            ps.setInt(3, eventId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 5. Notify Feedback Owner: Finds the member who wrote a specific feedback and notifies them
    public void notifyFeedbackOwner(int feedbackId, String subject, String messageBody) throws SQLException, ClassNotFoundException {
        String sql = "INSERT INTO notification (recipientID, subject, messageBody, sendDate) SELECT memberID, ?, ?, NOW() FROM feedback WHERE feedbackID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, subject);
            ps.setString(2, messageBody);
            ps.setInt(3, feedbackId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 6. Fetch user's notifications
    public List<Notification> getUserNotifications(String userID) throws SQLException, ClassNotFoundException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notification WHERE recipientID = ? ORDER BY sendDate DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Notification n = new Notification();
                n.setNotificationID(rs.getInt("notificationID"));
                n.setRecipientID(rs.getString("recipientID"));
                n.setSubject(rs.getString("subject"));
                n.setMessageBody(rs.getString("messageBody"));
                n.setSendDate(rs.getTimestamp("sendDate"));
                n.setRead(rs.getBoolean("isRead")); // <--- ADD THIS LINE
                list.add(n);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getUnreadCount(String userID) throws SQLException, ClassNotFoundException {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM notification WHERE recipientID = ? AND isRead = FALSE";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    public void markAsRead(int notificationID) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE notification SET isRead = TRUE WHERE notificationID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, notificationID);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void markAllAsRead(String userID) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE notification SET isRead = TRUE WHERE recipientID = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
