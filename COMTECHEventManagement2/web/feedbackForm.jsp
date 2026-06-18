<%-- 
    Document   : feedbackForm
    Created on : 17 Jun 2026, 4:12:58 pm
    Author     : Ainaa Nadhirah
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Authorization: Only Member can submit feedback
    String role = (String) session.getAttribute("userRole");
    String userId = (String) session.getAttribute("userId");
    
    if (!"MEMBER".equals(role)) {
        response.sendRedirect("login.jsp?error=unauthorized");
        return;
    }
    
    String eventID = request.getParameter("eventID");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Submit Feedback - COMTECH</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        .container { 
            padding: 30px; 
            max-width: 700px; 
            margin: auto; 
        }

        .main-content {
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
        }

        h2 { 
            color: #0d47a1; 
            margin-top: 0;
            border-bottom: 2px solid #f0f5ff;
            padding-bottom: 10px;
            margin-bottom: 25px;
        }
        
        .form-group {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        .form-group label {
            width: 150px;
            font-weight: bold;
            color: #333;
        }
        .form-group input, .form-group textarea, .form-group select {
            flex: 1;
            padding: 10px 15px;
            border: 2px solid #ccc;
            border-radius: 8px;
            font-family: inherit;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group textarea:focus, .form-group select:focus {
            border-color: #0d47a1;
            outline: none;
        }
        .form-group textarea {
            resize: vertical;
            min-height: 120px;
        }
        .form-group select {
            width: auto;
            flex: 1;
        }
        
        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 20px;
            padding-left: 150px;
        }
        .btn-submit {
            background-color: #0d47a1;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            font-size: 16px;
            transition: 0.3s;
        }
        .btn-submit:hover {
            background-color: #1565c0;
        }
        .btn-cancel {
            background-color: #757575;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            text-decoration: none;
            font-size: 16px;
            transition: 0.3s;
        }
        .btn-cancel:hover {
            background-color: #616161;
        }
        
        .alert-info {
            background-color: #e3f2fd;
            color: #0d47a1;
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #0d47a1;
        }
        
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #dc3545;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #28a745;
        }
        
        .no-event-msg {
            color: #999;
            font-style: italic;
        }
        
        .event-list {
            margin-top: 10px;
            padding: 10px;
            background: #f8f9fa;
            border-radius: 5px;
        }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp" />

    <div class="container">
        <div class="main-content">
            <h2>📝 Submit Event Feedback</h2>
            
            <%-- Display success/error messages --%>
            <% if ("success".equals(request.getParameter("msg"))) { %>
                <div class="alert-success">
                    <strong>✅ Success!</strong> Your feedback has been submitted successfully!
                </div>
            <% } %>
            
            <% if ("event_not_ended".equals(request.getParameter("error"))) { %>
                <div class="alert-error">
                    <strong>⛔ Error:</strong> You can only submit feedback for events that have already ended!
                </div>
            <% } %>
            
            <% if ("invalid_event".equals(request.getParameter("error"))) { %>
                <div class="alert-error">
                    <strong>⛔ Error:</strong> Invalid event selected. Please choose a valid event.
                </div>
            <% } %>
            
            <% if ("missing_data".equals(request.getParameter("error"))) { %>
                <div class="alert-error">
                    <strong>⛔ Error:</strong> Please fill in all required fields.
                </div>
            <% } %>
            
            <% if ("already_submitted".equals(request.getParameter("error"))) { %>
                <div class="alert-error">
                    <strong>⛔ Error:</strong> You have already submitted feedback for this event!
                </div>
            <% } %>
            
            <div class="alert-info">
                ℹ️ You can only submit feedback for events that you have attended and have already ended.
            </div>
            
            <form action="ReportFeedbackServlet" method="POST">
                <input type="hidden" name="action" value="submitFeedback">
                
                <div class="form-group">
                    <label for="eventID">Select Event:</label>
                    <select id="eventID" name="eventID" required>
                        <option value="">-- Select Event --</option>
                        <%
                            // ============================================================
                            // QUERY: Hanya tunjuk event yang:
                            // 1. Telah tamat (eventDate < CURDATE())
                            // 2. Telah diluluskan (status = 'Approved')
                            // 3. Pengguna telah mendaftar (JOIN event_registration)
                            // 4. Pengguna BELUM hantar feedback (NOT EXISTS)
                            // ============================================================
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/comtech_db", "root", "");
                                
                                String sql = "SELECT DISTINCT e.eventID, e.eventName, e.eventDate " +
                                             "FROM club_event e " +
                                             "INNER JOIN event_registration r ON e.eventID = r.eventID " +
                                             "WHERE e.status = 'Approved' " +
                                             "AND e.eventDate < CURDATE() " +
                                             "AND r.memberID = ? " +
                                             "AND r.status = 'Confirmed' " +
                                             "AND NOT EXISTS ( " +
                                             "    SELECT 1 FROM feedback f " +
                                             "    WHERE f.eventID = e.eventID AND f.memberID = ? " +
                                             ") " +
                                             "ORDER BY e.eventDate DESC";
                                
                                PreparedStatement st = conn.prepareStatement(sql);
                                st.setString(1, userId);
                                st.setString(2, userId);
                                ResultSet rs = st.executeQuery();
                                
                                boolean hasEvents = false;
                                while (rs.next()) {
                                    hasEvents = true;
                                    String id = rs.getString("eventID");
                                    String name = rs.getString("eventName");
                                    java.sql.Date eventDate = rs.getDate("eventDate");
                                    String selected = (eventID != null && eventID.equals(id)) ? "selected" : "";
                        %>
                                    <option value="<%= id %>" <%= selected %>>
                                        <%= name %> (📅 <%= eventDate %>)
                                    </option>
                        <%
                                }
                                
                                if (!hasEvents) {
                        %>
                                    <option value="" disabled class="no-event-msg">
                                        -- No completed events available for feedback --
                                    </option>
                                    <option value="" disabled class="no-event-msg" style="font-size:12px; color:#666;">
                                        (You need to attend an event first before giving feedback)
                                    </option>
                        <%
                                }
                                
                                rs.close();
                                st.close();
                                conn.close();
                            } catch (Exception e) {
                                e.printStackTrace();
                        %>
                                <option value="" disabled>-- Error loading events --</option>
                        <%
                            }
                        %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="rating">Rating:</label>
                    <select id="rating" name="rating" required>
                        <option value="5">⭐⭐⭐⭐⭐ - Excellent</option>
                        <option value="4">⭐⭐⭐⭐ - Good</option>
                        <option value="3" selected>⭐⭐⭐ - Average</option>
                        <option value="2">⭐⭐ - Poor</option>
                        <option value="1">⭐ - Very Poor</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="comment">Comment:</label>
                    <textarea id="comment" name="comment" required placeholder="Share your experience about this event..."></textarea>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn-submit">📤 Submit Feedback</button>
                    <a href="ReportFeedbackServlet?action=viewAll" class="btn-cancel">❌ Cancel</a>
                </div>
            </form>
            
            <%-- Show list of events the user has attended --%>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                <h4 style="color: #666; margin-bottom: 10px;">📋 Events You Have Attended:</h4>
                <%
                    try {
                        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/comtech_db", "root", "");
                        String listSql = "SELECT e.eventName, e.eventDate, " +
                                         "CASE WHEN f.feedbackID IS NOT NULL THEN '✅ Feedback Given' ELSE '⏳ Pending' END AS feedbackStatus " +
                                         "FROM club_event e " +
                                         "INNER JOIN event_registration r ON e.eventID = r.eventID " +
                                         "LEFT JOIN feedback f ON e.eventID = f.eventID AND f.memberID = ? " +
                                         "WHERE e.status = 'Approved' " +
                                         "AND e.eventDate < CURDATE() " +
                                         "AND r.memberID = ? " +
                                         "AND r.status = 'Confirmed' " +
                                         "ORDER BY e.eventDate DESC " +
                                         "LIMIT 5";
                        PreparedStatement st = conn.prepareStatement(listSql);
                        st.setString(1, userId);
                        st.setString(2, userId);
                        ResultSet rs = st.executeQuery();
                        
                        boolean hasEvents = false;
                        while (rs.next()) {
                            hasEvents = true;
                %>
                            <div style="display: flex; justify-content: space-between; padding: 8px 12px; background: #f8f9fa; margin-bottom: 5px; border-radius: 4px; border-left: 3px solid #0d47a1;">
                                <span><%= rs.getString("eventName") %> (📅 <%= rs.getDate("eventDate") %>)</span>
                                <span style="font-weight: bold; color: <%= rs.getString("feedbackStatus").contains("✅") ? "#28a745" : "#ffc107" %>;">
                                    <%= rs.getString("feedbackStatus") %>
                                </span>
                            </div>
                <%
                        }
                        if (!hasEvents) {
                %>
                            <p style="color: #999; font-style: italic; padding: 10px;">You haven't attended any completed events yet.</p>
                <%
                        }
                        rs.close();
                        st.close();
                        conn.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                %>
            </div>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>