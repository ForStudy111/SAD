<%-- 
    Document   : profile
    Created on : Jun 18, 2026, 1:35:13 PM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>My Profile</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container">
            <h2>Manage Profile</h2>

            <c:if test="${param.msg == 'success'}">
                <p style="color: green; font-weight: bold;">Profile updated successfully!</p>
            </c:if>
            <c:if test="${param.error == 'failed'}">
                <p style="color: red; font-weight: bold;">Failed to update profile. Please try again.</p>
            </c:if>

            <form action="ProfileServlet" method="POST" style="max-width: 500px; margin: auto; text-align: left;">

                <label>Full Name:</label>
                <input type="text" value="${profileData[5]}" readonly style="background-color: #eee; width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ccc;"><br>

                <label>Email Address (Username):</label>
                <input type="text" value="${profileData[0]}" readonly style="background-color: #eee; width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ccc;"><br>

                <label>System Role:</label>
                <input type="text" value="${sessionScope.userRole}" readonly style="background-color: #eee; width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ccc;"><br>

                <c:if test="${sessionScope.userRole != 'ADVISOR'}">
                    <label>Program / Position:</label>
                    <input type="text" value="${profileData[2]}" readonly style="background-color: #eee; width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ccc;"><br>

                    <label>Year:</label>
                    <input type="text" value="${profileData[3]}" readonly style="background-color: #eee; width: 100%; padding: 8px; margin-bottom: 10px; border: 1px solid #ccc;"><br>
                </c:if>

                <hr style="margin: 20px 0;">
                <h3>Update Your Contact Info</h3>

                <label>Phone Number:</label>
                <input type="text" name="phoneNo" value="${profileData[1]}" required style="width: 100%; padding: 8px; margin-bottom: 10px;"><br>

                <label>Password:</label>
                <input type="password" name="password" value="${profileData[4]}" required style="width: 100%; padding: 8px; margin-bottom: 20px;"><br>

                <button type="submit" class="btn" style="width: 100%; padding: 10px;">Save Changes</button>
            </form>
        </div>
    </body>
</html>
