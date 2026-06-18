<%-- 
    Document   : notification
    Created on : Jun 18, 2026, 1:35:54 PM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <title>System Notifications - COMTECH</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container" style="min-height: 80vh; padding: 20px;">
            <h2 style="color: #0033a0;">My Notifications</h2>
            <p>Stay updated with the latest event announcements and system alerts.</p>

            <!-- Broadcast Feature (Only visible to Committee) -->
            <c:if test="${sessionScope.userRole == 'COMMITTEE'}">
                <div style="background-color: #eef5fb; padding: 25px; border-radius: 8px; margin-bottom: 30px; border: 1px solid #cce0f5; box-shadow: 0 2px 5px rgba(0,0,0,0.05);">
                    <h3 style="color: #0033a0; margin-top: 0;">Broadcast a Message</h3>
                    <p>Send an announcement to all members, advisors, and committee members.</p>

                    <c:if test="${param.msg == 'broadcastSuccess'}">
                        <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                            <strong>Broadcast sent to all users successfully!</strong>
                        </div>
                    </c:if>

                    <form action="NotificationServlet" method="POST">
                        <input type="hidden" name="action" value="broadcast">
                        <input type="text" name="subject" placeholder="Broadcast Subject..." required style="width: 100%; padding: 12px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
                        <textarea name="messageBody" placeholder="Type your message here..." required style="width: 100%; padding: 12px; margin-bottom: 15px; height: 100px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; resize: vertical;"></textarea>

                        <!-- Fixed Button Styling -->
                        <button type="submit" style="background-color: #0033a0; color: white; padding: 10px 24px; border: none; border-radius: 5px; font-size: 15px; font-weight: bold; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">Send Broadcast</button>
                    </form>
                </div>
            </c:if>

            <!-- Notifications Table -->
            <c:choose>
                <c:when test="${empty notifList}">
                    <div style="background-color: #f9f9f9; padding: 20px; border: 1px solid #ddd; margin-top: 20px; border-radius: 5px;">
                        <p style="color: gray; font-style: italic; margin: 0; text-align: center;">You currently have no new notifications.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div style="text-align: right; margin-bottom: 10px;">
                        <a href="NotificationServlet?action=markAllRead" style="color: #0033a0; font-weight: bold; text-decoration: none;">✓ Mark All as Read</a>
                    </div>

                    <table class="table" border="1" style="width: 100%; text-align: left; border-collapse: collapse; box-shadow: 0 2px 5px rgba(0,0,0,0.1);">
                        <tr style="background-color: #0033a0; color: white;">
                            <th style="padding: 15px; width: 15%;">Date & Time</th>
                            <th style="padding: 15px; width: 25%;">Subject</th>
                            <th style="padding: 15px; width: 50%;">Message Details</th>
                            <th style="padding: 15px; width: 10%;">Status</th>
                        </tr>

                        <c:forEach var="notif" items="${notifList}">
                            <tr style="background-color: ${notif.read ? '#ffffff' : '#eef5fb'}; border-left: ${notif.read ? 'none' : '4px solid #0033a0'};">
                                <td style="padding: 15px; border-bottom: 1px solid #ddd; color: #555;">${notif.sendDate}</td>
                                <td style="padding: 15px; font-weight: ${notif.read ? 'normal' : 'bold'}; border-bottom: 1px solid #ddd; color: #333;">${notif.subject}</td>
                                <td style="padding: 15px; border-bottom: 1px solid #ddd; color: #444;">${notif.messageBody}</td>
                                <td style="padding: 15px; border-bottom: 1px solid #ddd; text-align: center;">
                                    <c:if test="${!notif.read}">
                                        <a href="NotificationServlet?action=markRead&id=${notif.notificationID}" style="color: #28a745; text-decoration: none; font-size: 14px; font-weight: bold;">Mark Read</a>
                                    </c:if>
                                    <c:if test="${notif.read}">
                                        <span style="color: #ccc; font-size: 14px;">Read</span>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Added Footer -->
        <jsp:include page="footer.jsp" />
    </body>
</html>
