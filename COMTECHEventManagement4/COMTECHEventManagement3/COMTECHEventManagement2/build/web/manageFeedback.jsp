<%-- 
    Document   : manageFeedback
    Created on : 13 May 2026
    Author     : Ainaa Nadhirah
--%>

<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Manage Feedback - COMTECH</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <style>
        /* Reset body margin to maximize width */
        body {
            margin: 0;
            padding: 0;
            background: #f5f7fa;
        }

        .container { 
            padding: 20px 40px; /* Reduced top/bottom, increased left/right */
            max-width: 100%; /* Full width */
            margin: 0; /* Remove auto margin */
            width: 100%;
            box-sizing: border-box;
        }

        .main-content {
            background: white;
            padding: 35px 45px; /* More horizontal padding */
            border-radius: 15px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            width: 100%;
            box-sizing: border-box;
        }

        .header-with-btn {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            gap: 20px;
            border-bottom: 2px solid #f0f5ff;
            padding-bottom: 10px;
        }

        h2 { 
            color: #0d47a1; 
            margin: 0;
            flex: 1;
            font-size: 24px;
        }

        .btn-submit-feedback {
            background-color: #0d47a1;
            color: white;
            padding: 10px 25px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: bold;
            font-size: 14px;
            transition: 0.3s;
            white-space: nowrap;
        }
        .btn-submit-feedback:hover {
            background-color: #1565c0;
            transform: scale(1.02);
        }
        
        /* Alert Messages */
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #28a745;
        }
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px 20px;
            border-radius: 6px;
            margin-bottom: 20px;
            border-left: 4px solid #dc3545;
        }
        
        /* Table Styling - FULL WIDTH */
        table { 
            width: 100%; 
            border-collapse: collapse; 
            border: 2px solid black; 
            table-layout: fixed; /* Ensures columns use assigned widths */
        }
        th { 
            background-color: #e3f2fd; 
            color: black; 
            border: 2px solid black; 
            padding: 14px 12px; 
            text-transform: uppercase;
            font-size: 14px;
        }
        td { 
            border: 2px solid black; 
            padding: 14px 12px; 
            text-align: center; 
            font-size: 14px;
            color: #333; 
            word-wrap: break-word; /* Prevents overflow */
        }
        tr:nth-child(even) { background-color: #fcfcfc; }

        /* Column Widths - Adjusted to fill space */
        th:nth-child(1), td:nth-child(1) { width: 20%; }  /* Event Name */
        th:nth-child(2), td:nth-child(2) { width: 10%; }  /* Rating */
        th:nth-child(3), td:nth-child(3) { width: 32%; }  /* Comment */
        th:nth-child(4), td:nth-child(4) { width: 12%; }  /* Date */
        th:nth-child(5), td:nth-child(5) { width: 10%; }  /* Replies */
        th:nth-child(6), td:nth-child(6) { width: 16%; }  /* Actions */

        /* Action Buttons Styling */
        .btn-update {
            color: #0d47a1;
            text-decoration: none;
            font-weight: bold;
            margin-right: 12px;
        }
        .btn-delete {
            color: #d32f2f;
            text-decoration: none;
            font-weight: bold;
            margin-right: 12px;
        }
        .btn-reply {
            color: #2e7d32;
            text-decoration: none;
            font-weight: bold;
        }
        .btn-update:hover, .btn-delete:hover, .btn-reply:hover { 
            text-decoration: underline; 
        }
        .view-only { 
            color: #757575; 
            font-style: italic; 
            font-size: 13px; 
        }
        
        .badge-reply {
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: bold;
        }
        
        /* Responsive */
        @media (max-width: 992px) {
            .container {
                padding: 15px 20px;
            }
            .main-content {
                padding: 20px 25px;
            }
            /* Stack columns on smaller screens */
            table {
                table-layout: auto;
            }
            th:nth-child(1), td:nth-child(1),
            th:nth-child(2), td:nth-child(2),
            th:nth-child(3), td:nth-child(3),
            th:nth-child(4), td:nth-child(4),
            th:nth-child(5), td:nth-child(5),
            th:nth-child(6), td:nth-child(6) {
                width: auto;
            }
        }

        @media (max-width: 768px) {
            .header-with-btn {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            .btn-submit-feedback {
                width: 100%;
                text-align: center;
            }
            .container {
                padding: 10px 12px;
            }
            .main-content {
                padding: 15px 18px;
            }
            /* Make table scrollable on mobile */
            .table-wrapper {
                overflow-x: auto;
                -webkit-overflow-scrolling: touch;
            }
            table {
                font-size: 13px;
                min-width: 700px;
            }
            th, td {
                padding: 10px 8px;
            }
        }

        /* Remove any extra margins from navbar/footer if needed */
        .navbar, .footer {
            width: 100%;
            box-sizing: border-box;
        }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp" />

    <div class="container">
        <div class="main-content">
            
            <!-- HEADER WITH BUTTON -->
            <div class="header-with-btn">
                <h2>Manage Event Feedback</h2>
                
                <%-- Only MEMBER can submit new feedback --%>
                <% String role = (String) session.getAttribute("userRole"); 
                   if ("MEMBER".equals(role)) { %>
                    <a href="feedbackForm.jsp" class="btn-submit-feedback">➕ Submit New Feedback</a>
                <% } %>
            </div>
            
            <% 
                // Get user session data
                String userId = (String) session.getAttribute("userId");
                
                // Display messages
                String msg = request.getParameter("msg");
                String error = request.getParameter("error");
                
                if (msg != null) {
                    if ("Submitted".equals(msg)) {
            %>
                <div class="alert-success">✅ Your feedback has been submitted successfully!</div>
            <%      } else if ("Updated".equals(msg)) { %>
                <div class="alert-success">✅ Your feedback has been updated successfully!</div>
            <%      } else if ("Deleted".equals(msg)) { %>
                <div class="alert-success">✅ Feedback has been deleted successfully!</div>
            <%      } else if ("ReplySent".equals(msg)) { %>
                <div class="alert-success">✅ Your reply has been sent successfully!</div>
            <%      }
                } else if (error != null && "unauthorized".equals(error)) { 
            %>
                <div class="alert-error">⛔ You are not authorized to perform this action.</div>
            <% } %>
            
            <%
                // Retrieve the filtered list from Servlet
                List<Map<String, Object>> list = (List<Map<String, Object>>) request.getAttribute("feedbackList");
                if (list == null) list = new ArrayList<>(); 
            %>

            <!-- Wrap table for mobile scroll -->
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Event Name</th>
                            <th>Rating</th>
                            <th>Comment</th>
                            <th>Date</th>
                            <th>Replies</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (list.isEmpty()) { %>
                            <tr>
                                <td colspan="6" style="padding: 40px; color: #757575; text-align: center;">No feedback records found.</td>
                            </tr>
                        <% } else { 
                            for(Map<String, Object> f : list) { 
                                int replyCount = (int) f.get("replyCount");
                                String feedbackID = String.valueOf(f.get("feedbackID"));
                                String comment = (String) f.get("comment");
                                String eventName = (String) f.get("eventName");
                                int rating = (int) f.get("rating");
                                String ownerID = (String) f.get("memberID");
                                boolean isOwner = userId != null && userId.equals(ownerID);
                        %>
                            <tr>
                                <td style="text-align: left; font-weight: bold;"><%= eventName %></td>
                                <td style="color: #f39c12; font-weight: bold;"><%= rating %> / 5</td>
                                <td style="text-align: left;"><%= comment %></td>
                                <td><%= f.get("submissionDate") %></td>
                                <td>
                                    <a href="ReportFeedbackServlet?action=viewReplies&feedbackID=<%= feedbackID %>" class="btn-reply">
                                        <span class="badge-reply">💬 <%= replyCount %></span>
                                    </a>
                                </td>
                                <td>
                                    <%-- ACTION LOGIC BASED ON ROLE --%>
                                    
                                    <% if ("MEMBER".equals(role) && isOwner) { %>
                                        <%-- Members can Update and Delete their own feedback --%>
                                        <a href="updateFeedback.jsp?id=<%= feedbackID %>&comment=<%= comment %>&rating=<%= rating %>&eventID=<%= f.get("eventID") %>" 
                                           class="btn-update">Update</a>
                                        
                                        <a href="ReportFeedbackServlet?action=delete&id=<%= feedbackID %>" 
                                           class="btn-delete"
                                           onclick="return confirm('Are you sure you want to delete your feedback?')">Delete</a>

                                    <% } else if ("COMMITTEE".equals(role)) { %>
                                        <%-- Committee can reply and delete any feedback --%>
                                        <a href="replyFeedback.jsp?feedbackID=<%= feedbackID %>" 
                                           class="btn-reply">Reply</a>
                                        
                                        <a href="ReportFeedbackServlet?action=delete&id=<%= feedbackID %>" 
                                           class="btn-delete"
                                           onclick="return confirm('As Committee, confirm deletion of this feedback?')">Delete</a>

                                    <% } else if ("ADVISOR".equals(role)) { %>
                                        <%-- Advisor can reply to any feedback --%>
                                        <a href="replyFeedback.jsp?feedbackID=<%= feedbackID %>" 
                                           class="btn-reply">Reply</a>
                                        <span class="view-only">View Only</span>

                                    <% } else { %>
                                        <%-- View Only for others --%>
                                        <span class="view-only">View Only</span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>