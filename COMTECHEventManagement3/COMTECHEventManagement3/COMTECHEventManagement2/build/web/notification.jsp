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
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>System Notifications</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container">
            <h2>My Notifications</h2>
            <p>Stay updated with the latest event announcements and system alerts.</p>

            <c:choose>
                <c:when test="${empty notifList}">
                    <div style="background-color: #f9f9f9; padding: 20px; border: 1px solid #ddd; margin-top: 20px;">
                        <p style="color: gray; font-style: italic; margin: 0;">You currently have no new notifications.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <table class="table" border="1" style="width: 100%; text-align: left; border-collapse: collapse; margin-top: 20px;">
                        <tr style="background-color: #f2f2f2;">
                            <th style="padding: 12px; width: 20%;">Date & Time</th>
                            <th style="padding: 12px; width: 25%;">Subject</th>
                            <th style="padding: 12px; width: 55%;">Message Details</th>
                        </tr>

                        <c:forEach var="notif" items="${notifList}">
                            <tr>
                                <td style="padding: 12px; border-bottom: 1px solid #ddd;">
                                    ${notif.sendDate}
                                </td>
                                <td style="padding: 12px; font-weight: bold; border-bottom: 1px solid #ddd;">
                                    ${notif.subject}
                                </td>
                                <td style="padding: 12px; border-bottom: 1px solid #ddd;">
                                    ${notif.messageBody}
                                </td>
                            </tr>
                        </c:forEach>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </body>
</html>
