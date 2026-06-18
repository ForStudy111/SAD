<%-- 
    Document   : committeeManageMembers
    Created on : Jun 18, 2026, 1:29:01 PM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Manage Club Members</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container">
            <h2>Club Members List</h2>
            <p>Review the list below to identify and remove inactive members.</p>

            <c:if test="${param.msg == 'deleted'}">
                <p style="color: green; font-weight: bold;">Inactive member successfully removed.</p>
            </c:if>

            <table class="table" border="1" style="width: 100%; text-align: left;">
                <tr style="background-color: #f2f2f2;">
                    <th>Member ID</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Program</th>
                    <th>Action</th>
                </tr>
                <c:forEach var="member" items="${memberList}">
                    <tr>
                        <td>${member.memberID}</td>
                        <td>${member.name}</td>
                        <td>${member.email}</td>
                        <td>${member.program}</td>
                        <td>
                            <a href="ManageMembersServlet?action=delete&id=${member.memberID}" 
                               onclick="return confirm('Are you sure you want to remove this inactive member? This action cannot be undone.');" 
                               style="color: red; text-decoration: none; font-weight: bold;">
                                Remove
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </table>
        </div>
    </body>
</html>
