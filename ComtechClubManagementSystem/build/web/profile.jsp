<%-- 
    Document   : profile
    Created on : May 13, 2026, 11:30:31 AM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Manage Profile - COMTECH</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <nav class="navbar navbar-dark bg-primary mb-4">
            <div class="container"><span class="navbar-brand mb-0 h1">COMTECH System</span></div>
        </nav>
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card shadow">
                        <div class="card-header bg-white text-primary fs-4 fw-bold">My Profile</div>
                        <div class="card-body">
                            <% if (request.getAttribute("message") != null) { %>
                            <div class="alert alert-success">${message}</div>
                            <% }%>
                            <form action="profile" method="POST">
                                <div class="mb-3">
                                    <label>Member ID</label>
                                    <input type="text" class="form-control" value="${member.memberID}" readonly>
                                </div>
                                <div class="mb-3">
                                    <label>Name</label>
                                    <input type="text" class="form-control" value="${member.name}" readonly>
                                </div>
                                <div class="mb-3">
                                    <label>Program</label>
                                    <input type="text" class="form-control" value="${member.program}" readonly>
                                </div>
                                <div class="mb-3">
                                    <label>Phone Number (Editable)</label>
                                    <input type="text" name="phoneNo" class="form-control" value="${member.phoneNo}" required>
                                </div>
                                <div class="mb-3">
                                    <label>Password (Editable)</label>
                                    <input type="password" name="password" class="form-control" value="${member.password}" required>
                                </div>
                                <button type="submit" class="btn btn-primary w-100">Submit Updates</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
</html>
