/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.lab.controller;

import com.lab.dao.DBConnection;
import com.lab.dao.NotificationDAO;
import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * Servlet for managing feedback and generating reports
 * @author Ainaa Nadhirah
 */
@WebServlet(name = "ReportFeedbackServlet", urlPatterns = {"/ReportFeedbackServlet"})
public class ReportFeedbackServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if ("viewAll".equals(action)) {
                viewFeedbackList(request, response);
            } else if ("delete".equals(action)) {
                deleteFeedback(request, response);
            } else if ("generateReport".equals(action)) {
                generateReport(request, response);
            } else if ("submitFeedback".equals(action)) {
                submitFeedback(request, response);
            } else if ("updateFeedback".equals(action)) {
                updateFeedback(request, response);
            } else if ("replyFeedback".equals(action)) {
                replyFeedback(request, response);
            } else if ("viewReplies".equals(action)) {
                viewReplies(request, response);
            } else {
                response.sendRedirect("home.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    // ================================================================
    // METHOD 1: SUBMIT FEEDBACK (WITH VALIDATION)
    // ================================================================
    private void submitFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String eventIDStr = request.getParameter("eventID");
        String ratingStr = request.getParameter("rating");
        String comment = request.getParameter("comment");
        
        // Validation 1: Check required fields
        if (eventIDStr == null || eventIDStr.isEmpty() || ratingStr == null || ratingStr.isEmpty()) {
            response.sendRedirect("feedbackForm.jsp?error=missing_data");
            return;
        }

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("userRole");

        // Security: Only MEMBER can submit feedback
        if (!"MEMBER".equals(role)) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        Connection conn = null;
        PreparedStatement checkSt = null;
        PreparedStatement checkFeedbackSt = null;
        PreparedStatement insertSt = null;
        ResultSet rs = null;
        ResultSet feedbackRs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            int eventID = Integer.parseInt(eventIDStr);
            int rating = Integer.parseInt(ratingStr);

            // ============================================================
            // VALIDATION 2: Check if event exists, is approved, and has ended
            // ============================================================
            String checkSql = "SELECT eventDate, eventName FROM club_event WHERE eventID = ? AND status = 'Approved'";
            checkSt = conn.prepareStatement(checkSql);
            checkSt.setInt(1, eventID);
            rs = checkSt.executeQuery();
            
            String eventName = "";
            if (rs.next()) {
                java.sql.Date eventDate = rs.getDate("eventDate");
                java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
                eventName = rs.getString("eventName");
                
                // CRITICAL: If eventDate >= today, event hasn't ended yet
                if (!eventDate.before(today)) {
                    response.sendRedirect("feedbackForm.jsp?error=event_not_ended");
                    return;
                }
            } else {
                // Event not found or not approved
                response.sendRedirect("feedbackForm.jsp?error=invalid_event");
                return;
            }

            // ============================================================
            // VALIDATION 3: Check if user already submitted feedback for this event
            // ============================================================
            String checkFeedbackSql = "SELECT COUNT(*) FROM feedback WHERE eventID = ? AND memberID = ?";
            checkFeedbackSt = conn.prepareStatement(checkFeedbackSql);
            checkFeedbackSt.setInt(1, eventID);
            checkFeedbackSt.setString(2, userID);
            feedbackRs = checkFeedbackSt.executeQuery();
            
            if (feedbackRs.next() && feedbackRs.getInt(1) > 0) {
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=already_submitted");
                return;
            }

            // ============================================================
            // PROCEED: Insert the feedback
            // ============================================================
            String insertSql = "INSERT INTO feedback (eventID, memberID, rating, comment, submissionDate) VALUES (?, ?, ?, ?, CURDATE())";
            insertSt = conn.prepareStatement(insertSql);
            insertSt.setInt(1, eventID);
            insertSt.setString(2, userID);
            insertSt.setInt(3, rating);
            insertSt.setString(4, comment);
            int rowsAffected = insertSt.executeUpdate();
            
            if (rowsAffected > 0) {
                conn.commit();
                
                try {
                    NotificationDAO notifDAO = new NotificationDAO();
                    notifDAO.addNotification(userID, "✅ Feedback Submitted", 
                        "Your feedback for '" + eventName + "' was successfully submitted. Thank you for your input! <a href='ReportFeedbackServlet?action=viewAll'>View My Feedback</a>.");
                } catch (Exception e) {
                    e.printStackTrace();
                }
                
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Submitted");
            } else {
                conn.rollback();
                response.sendRedirect("feedbackForm.jsp?error=submit_failed");
            }

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("feedbackForm.jsp?error=database_error");
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("feedbackForm.jsp?error=unknown");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (feedbackRs != null) feedbackRs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (checkSt != null) checkSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (checkFeedbackSt != null) checkFeedbackSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (insertSt != null) insertSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ================================================================
    // METHOD 2: UPDATE FEEDBACK
    // ================================================================
    private void updateFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("feedbackID"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String comment = request.getParameter("comment");
        
        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("userRole");

        if (!"MEMBER".equals(role)) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        Connection conn = null;
        PreparedStatement checkSt = null;
        PreparedStatement updateSt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String checkSql = "SELECT memberID FROM feedback WHERE feedbackID = ?";
            checkSt = conn.prepareStatement(checkSql);
            checkSt.setInt(1, feedbackID);
            rs = checkSt.executeQuery();
            
            if (rs.next()) {
                String ownerID = rs.getString("memberID");
                if (!ownerID.equals(userID)) {
                    response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=unauthorized");
                    return;
                }
            } else {
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=not_found");
                return;
            }

            String updateSql = "UPDATE feedback SET rating = ?, comment = ?, submissionDate = CURDATE() WHERE feedbackID = ?";
            updateSt = conn.prepareStatement(updateSql);
            updateSt.setInt(1, rating);
            updateSt.setString(2, comment);
            updateSt.setInt(3, feedbackID);
            
            if (updateSt.executeUpdate() > 0) {
                conn.commit();
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Updated");
            } else {
                conn.rollback();
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=update_failed");
            }

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=database_error");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (checkSt != null) checkSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (updateSt != null) updateSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ================================================================
    // METHOD 3: DELETE FEEDBACK
    // ================================================================
    private void deleteFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("id"));
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        String userID = (String) session.getAttribute("userId");

        Connection conn = null;
        PreparedStatement checkSt = null;
        PreparedStatement deleteRepliesSt = null;
        PreparedStatement deleteSt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            if ("MEMBER".equals(role)) {
                String checkSql = "SELECT memberID FROM feedback WHERE feedbackID = ?";
                checkSt = conn.prepareStatement(checkSql);
                checkSt.setInt(1, feedbackID);
                rs = checkSt.executeQuery();
                if (rs.next()) {
                    String ownerID = rs.getString("memberID");
                    if (!ownerID.equals(userID)) {
                        response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=unauthorized");
                        return;
                    }
                } else {
                    response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=not_found");
                    return;
                }
            }
            
            String deleteRepliesSql = "DELETE FROM feedback_replies WHERE feedbackID = ?";
            deleteRepliesSt = conn.prepareStatement(deleteRepliesSql);
            deleteRepliesSt.setInt(1, feedbackID);
            deleteRepliesSt.executeUpdate();
            
            String deleteSql = "DELETE FROM feedback WHERE feedbackID = ?";
            deleteSt = conn.prepareStatement(deleteSql);
            deleteSt.setInt(1, feedbackID);
            
            if (deleteSt.executeUpdate() > 0) {
                conn.commit();
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&msg=Deleted");
            } else {
                conn.rollback();
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=delete_failed");
            }

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=database_error");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (checkSt != null) checkSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (deleteRepliesSt != null) deleteRepliesSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (deleteSt != null) deleteSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ================================================================
    // METHOD 4: VIEW FEEDBACK LIST
    // ================================================================
    private void viewFeedbackList(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        String userID = (String) session.getAttribute("userId");

        List<Map<String, Object>> feedbackList = new ArrayList<>();

        Connection conn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            
            String sql = "SELECT f.*, e.eventName, " +
                         "(SELECT COUNT(*) FROM feedback_replies fr WHERE fr.feedbackID = f.feedbackID) AS replyCount " +
                         "FROM feedback f JOIN club_event e ON f.eventID = e.eventID";
            
            if ("MEMBER".equals(role)) {
                sql += " WHERE f.memberID = ?";
            }
            
            sql += " ORDER BY f.submissionDate DESC";

            st = conn.prepareStatement(sql);
            if ("MEMBER".equals(role)) {
                st.setString(1, userID);
            }

            rs = st.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("feedbackID", rs.getInt("feedbackID"));
                row.put("eventID", rs.getInt("eventID"));
                row.put("eventName", rs.getString("eventName"));
                row.put("rating", rs.getInt("rating"));
                row.put("comment", rs.getString("comment"));
                row.put("memberID", rs.getString("memberID"));
                row.put("submissionDate", rs.getDate("submissionDate"));
                row.put("replyCount", rs.getInt("replyCount"));
                feedbackList.add(row);
            }
            
            request.setAttribute("feedbackList", feedbackList);
            request.getRequestDispatcher("manageFeedback.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("home.jsp?error=database_error");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (st != null) st.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ================================================================
    // METHOD 5: REPLY TO FEEDBACK
    // ================================================================
    private void replyFeedback(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("feedbackID"));
        String replyText = request.getParameter("replyText");
        
        HttpSession session = request.getSession();
        String replierID = (String) session.getAttribute("userId");
        String replierRole = (String) session.getAttribute("userRole");

        if (!"COMMITTEE".equals(replierRole) && !"ADVISOR".equals(replierRole)) {
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=unauthorized");
            return;
        }

        Connection conn = null;
        PreparedStatement st = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String sql = "INSERT INTO feedback_replies (feedbackID, replierID, replierRole, replyText, replyDate) VALUES (?, ?, ?, ?, CURDATE())";
            st = conn.prepareStatement(sql);
            st.setInt(1, feedbackID);
            st.setString(2, replierID);
            st.setString(3, replierRole);
            st.setString(4, replyText);
            
            int rowsAffected = st.executeUpdate();
            
            if (rowsAffected > 0) {
                conn.commit();
                
                try {
                    NotificationDAO notifDAO = new NotificationDAO();
                    notifDAO.notifyFeedbackOwner(feedbackID, "💬 Reply to Your Feedback", 
                        "A " + replierRole.toLowerCase() + " has replied to your event feedback. <a href='ReportFeedbackServlet?action=viewReplies&feedbackID=" + feedbackID + "'>Click here to read the reply</a>.");
                } catch (Exception e) {
                    e.printStackTrace();
                }
                
                response.sendRedirect("ReportFeedbackServlet?action=viewReplies&feedbackID=" + feedbackID + "&msg=ReplySent");
            } else {
                conn.rollback();
                response.sendRedirect("ReportFeedbackServlet?action=viewReplies&feedbackID=" + feedbackID + "&error=reply_failed");
            }

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            response.sendRedirect("ReportFeedbackServlet?action=viewReplies&feedbackID=" + feedbackID + "&error=database_error");
        } finally {
            try { if (st != null) st.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ================================================================
    // METHOD 6: VIEW REPLIES
    // ================================================================
    private void viewReplies(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int feedbackID = Integer.parseInt(request.getParameter("feedbackID"));
        
        List<Map<String, Object>> replyList = new ArrayList<>();
        Map<String, Object> feedback = new HashMap<>();

        Connection conn = null;
        PreparedStatement feedbackSt = null;
        PreparedStatement replySt = null;
        ResultSet feedbackRs = null;
        ResultSet replyRs = null;

        try {
            conn = DBConnection.getConnection();

            String feedbackSql = "SELECT f.*, e.eventName FROM feedback f JOIN club_event e ON f.eventID = e.eventID WHERE f.feedbackID = ?";
            feedbackSt = conn.prepareStatement(feedbackSql);
            feedbackSt.setInt(1, feedbackID);
            feedbackRs = feedbackSt.executeQuery();
            
            if (feedbackRs.next()) {
                feedback.put("feedbackID", feedbackRs.getInt("feedbackID"));
                feedback.put("eventName", feedbackRs.getString("eventName"));
                feedback.put("rating", feedbackRs.getInt("rating"));
                feedback.put("comment", feedbackRs.getString("comment"));
                feedback.put("memberID", feedbackRs.getString("memberID"));
                feedback.put("submissionDate", feedbackRs.getDate("submissionDate"));
            } else {
                response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=not_found");
                return;
            }
            
            String replySql = "SELECT * FROM feedback_replies WHERE feedbackID = ? ORDER BY replyDate ASC";
            replySt = conn.prepareStatement(replySql);
            replySt.setInt(1, feedbackID);
            replyRs = replySt.executeQuery();
            
            while (replyRs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("replyID", replyRs.getInt("replyID"));
                row.put("replierID", replyRs.getString("replierID"));
                row.put("replierRole", replyRs.getString("replierRole"));
                row.put("replyText", replyRs.getString("replyText"));
                row.put("replyDate", replyRs.getDate("replyDate"));
                replyList.add(row);
            }
            
            request.setAttribute("feedback", feedback);
            request.setAttribute("replyList", replyList);
            request.getRequestDispatcher("viewFeedbackReplies.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("ReportFeedbackServlet?action=viewAll&error=database_error");
        } finally {
            try { if (feedbackRs != null) feedbackRs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (replyRs != null) replyRs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (feedbackSt != null) feedbackSt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (replySt != null) replySt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    // ================================================================
    // METHOD 7: GENERATE REPORT
    // ================================================================
    private void generateReport(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        String viewMode = request.getParameter("viewMode");

        if (monthStr == null || yearStr == null) {
            response.sendRedirect("generateReportForm.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement st = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            
            String sql = "SELECT e.*, " +
                         "(SELECT COUNT(*) FROM event_registration r WHERE r.eventID = e.eventID AND r.status = 'Confirmed') as actualPart, " +
                         "(SELECT AVG(f.rating) FROM feedback f WHERE f.eventID = e.eventID) as avgScore " +
                         "FROM club_event e " +
                         "WHERE MONTH(e.eventDate) = ? AND YEAR(e.eventDate) = ? AND e.status = 'Approved' " +
                         "GROUP BY e.eventID";
            
            st = conn.prepareStatement(sql);
            st.setInt(1, Integer.parseInt(monthStr));
            st.setInt(2, Integer.parseInt(yearStr));
            
            rs = st.executeQuery();

            List<Map<String, Object>> reportData = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("eventName", rs.getString("eventName"));
                row.put("eventDate", rs.getDate("eventDate"));
                row.put("venue", rs.getString("venue"));
                row.put("category", "Academic");
                row.put("level", "Universiti");
                
                Time startTime = rs.getTime("startTime");
                Time endTime = rs.getTime("endTime");
                String timeStr = (startTime != null && endTime != null) ? 
                    startTime.toString().substring(0, 5) + " - " + endTime.toString().substring(0, 5) : "TBA";
                row.put("time", timeStr);
                
                int totalPart = rs.getInt("capacity");
                int actualPart = rs.getInt("actualPart");
                row.put("totalPart", totalPart);
                row.put("actualPart", actualPart);
                
                double attendanceRate = (totalPart > 0) ? ((double) actualPart / totalPart) * 100 : 0;
                row.put("attendanceRate", attendanceRate);
                
                double score = rs.getDouble("avgScore");
                row.put("avgScore", rs.wasNull() ? 0.0 : score);
                
                reportData.add(row);
            }

            String[] monthNames = {"", "January", "February", "March", "April", "May", "June", 
                                   "July", "August", "September", "October", "November", "December"};
            String monthName = monthNames[Integer.parseInt(monthStr)];

            request.setAttribute("reportData", reportData);
            request.setAttribute("viewMode", (viewMode == null) ? "both" : viewMode);
            request.setAttribute("selectedMonthName", monthName);
            request.setAttribute("selectedYear", yearStr);
            
            request.getRequestDispatcher("viewReport.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("generateReportForm.jsp?error=database_error");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (st != null) st.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}