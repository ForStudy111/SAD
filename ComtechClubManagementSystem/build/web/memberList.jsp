<%-- 
    Document   : memberList
    Created on : May 13, 2026, 11:32:24 AM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="java" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Manage Members - COMTECH</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <nav class="navbar navbar-dark bg-primary mb-4">
            <div class="container"><span class="navbar-brand mb-0 h1">COMTECH System - Committee Dashboard</span></div>
        </nav>
        <div class="container">
            <div class="card shadow">
                <div class="card-header bg-white text-primary fs-4 fw-bold">Registered Club Members</div>
                <div class="card-body">
                    <table class="table table-bordered table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>Member ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Program</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="m" items="${memberList}">
                                <tr>
                                    <td>${m.memberID}</td>
                                    <td>${m.name}</td>
                                    <td>${m.email}</td>
                                    <td>${m.program}</td>
                                    <td>
                                        <a href="manageMembers?action=delete&id=${m.memberID}" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this profile?');">Delete Profile</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </body>
</html>
