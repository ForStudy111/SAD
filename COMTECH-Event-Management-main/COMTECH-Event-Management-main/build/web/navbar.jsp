<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Get the user's role from the session to decide which menus to show
    String navRole = (String) session.getAttribute("userRole"); 
%>
<div class="navbar">
    <div class="logo">
        <a href="home.jsp" style="display: flex; align-items: center; text-decoration: none; color: white; font-family: Palatino">
            <img src="images/COMTECH.png" alt="COMTECH Logo" class="nav-logo-img">
            <h2 style="margin: 0;">COMTECH</h2>
        </a>
    </div>
    
    <div class="nav-links">
        <a href="home.jsp">Home</a>
        
        <% if ("ADVISOR".equals(navRole)) { %>
            <a href="EventServlet?action=listPending">Event Approval</a>
            <a href="MemberServlet">Manage Members</a>
            <a href="EventServlet?action=advisorReservations">Reservations</a> 
            <a href="#">Feedback</a>
            <a href="#">Reports</a>
            <a href="#">Notifications</a>

        <% } else if ("COMMITTEE".equals(navRole)) { %>
            <a href="createEvent.jsp">Manage Events</a>
            <a href="EventServlet?action=committeeReservations">Reservations</a> 
            <a href="#">Feedback</a>
            <a href="#">Reports</a>
            <a href="#">Notifications</a>

        <% } else if ("MEMBER".equals(navRole)) { %>
            <a href="EventServlet?action=browse">Browse Events</a>        
            <a href="EventServlet?action=myReservations">My Reservations</a>
            <a href="#">Feedback Form</a>
            <a href="#">Notifications</a>
        <% } %>

        <div class="profile-menu">
            <div class="profile-icon">👤</div>
            <div class="dropdown-content">
                <a href="#" style="color: blue !important; font-weight: 600 !important;">Manage Profile</a>
                <hr style="margin: 0; border: none; border-top: 1px solid #eee;">
                <a href="login.jsp" style="color: #F44336 !important; font-weight: 600 !important;">Logout</a>
            </div>
        </div>

    </div>
</div>