/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package comtech.dao;
import comtech.model.ClubMember;
import comtech.model.Notification;
import comtech.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author wpy92
 */
public class SystemDAO {

    // --- MODULE 1: PROFILE MANAGEMENT ---
    public ClubMember getMemberById(String memberId) {
        ClubMember member = null;
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("SELECT * FROM ClubMember WHERE memberID=?")) {
            ps.setString(1, memberId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                member = new ClubMember();
                member.setMemberID(rs.getString("memberID"));
                member.setName(rs.getString("name"));
                member.setEmail(rs.getString("email"));
                member.setPhoneNo(rs.getString("phoneNo"));
                member.setPassword(rs.getString("password"));
                member.setProgram(rs.getString("program"));
                member.setYear(rs.getInt("year"));
            }
        } 
        catch (SQLException e) {
            e.printStackTrace();
        }
        return member;
    }

    public boolean updateProfile(String memberId, String phone, String password) {
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("UPDATE ClubMember SET phoneNo=?, password=? WHERE memberID=?")) {
            ps.setString(1, phone);
            ps.setString(2, password);
            ps.setString(3, memberId);
            return ps.executeUpdate() > 0;
        } 
        catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // --- MODULE 2: MANAGE CLUB MEMBERS (COMMITTEE VIEW) ---
    public List<ClubMember> getAllMembers() {
        List<ClubMember> members = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("SELECT * FROM ClubMember"); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                ClubMember m = new ClubMember();
                m.setMemberID(rs.getString("memberID"));
                m.setName(rs.getString("name"));
                m.setEmail(rs.getString("email"));
                m.setProgram(rs.getString("program"));
                members.add(m);
            }
        } 
        catch (SQLException e) {
            e.printStackTrace();
        }
        return members;
    }

    public boolean deleteMember(String memberId) {
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("DELETE FROM ClubMember WHERE memberID=?")) {
            ps.setString(1, memberId);
            return ps.executeUpdate() > 0;
        } 
        catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // --- MODULE 3: MANAGE NOTIFICATIONS ---
    public List<Notification> getNotificationsForMember(String memberId) {
        List<Notification> notifications = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement("SELECT * FROM Notification WHERE memberID=? ORDER BY sendDate DESC")) {
            ps.setString(1, memberId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Notification n = new Notification();
                n.setNotificationID(rs.getInt("notificationID"));
                n.setSubject(rs.getString("subject"));
                n.setMessageBody(rs.getString("messageBody"));
                n.setSendDate(rs.getDate("sendDate"));
                notifications.add(n);
            }
        } 
        catch (SQLException e) {
            e.printStackTrace();
        }
        return notifications;
    }
}
