<%-- 
    Document   : notification
    Created on : May 13, 2026, 11:35:58 AM
    Author     : wpy92
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page language="java" %>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Notifications - COMTECH</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <nav class="navbar navbar-dark bg-primary mb-4">
            <div class="container"><span class="navbar-brand mb-0 h1">COMTECH System</span></div>
        </nav>
        <div class="container">
            <h2 class="text-primary fw-bold mb-4">My Notifications</h2>
            <div class="row">
                <c:forEach var="notif" items="${notifList}">
                    <div class="col-12 mb-3">
                        <div class="card shadow-sm border-start border-primary border-4">
                            <div class="card-body">
                                <h5 class="card-title text-dark">${notif.subject}</h5>
                                <h6 class="card-subtitle mb-2 text-muted">Sent: ${notif.sendDate}</h6>
                                <p class="card-text">${notif.messageBody}</p>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </body>
</html>
