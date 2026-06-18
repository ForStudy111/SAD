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
        <title>My Profile - COMTECH</title>
        <link rel="stylesheet" href="style.css">
    </head>
    <body>
        <jsp:include page="navbar.jsp" />

        <div class="container" style="min-height: 80vh; padding: 20px;">
            <h2 style="text-align: center; color: #0033a0;">Manage Profile</h2>

            <!-- Display Success or Error Messages -->
            <c:if test="${param.msg == 'success'}">
                <div style="background-color: #d4edda; color: #155724; padding: 10px; border-radius: 5px; text-align: center; margin-bottom: 15px;">
                    <strong>Profile updated successfully!</strong>
                </div>
            </c:if>
            <c:if test="${param.error == 'failed'}">
                <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; text-align: center; margin-bottom: 15px;">
                    <strong>Failed to update profile. Please try again.</strong>
                </div>
            </c:if>

            <div style="max-width: 600px; margin: 0 auto; background-color: #f9fbfd; padding: 30px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
                <form action="ProfileServlet" method="POST">

                    <label style="font-weight: bold; color: #333;">Full Name:</label>
                    <input type="text" value="${profileData[5]}" readonly style="background-color: #e9ecef; width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;"><br>

                    <label style="font-weight: bold; color: #333;">Email Address (Username):</label>
                    <input type="text" value="${profileData[0]}" readonly style="background-color: #e9ecef; width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;"><br>

                    <label style="font-weight: bold; color: #333;">System Role:</label>
                    <input type="text" value="${sessionScope.userRole}" readonly style="background-color: #e9ecef; width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;"><br>

                    <!-- Hide Program and Year if the logged-in user is an ADVISOR -->
                    <c:if test="${sessionScope.userRole != 'ADVISOR'}">
                        <label style="font-weight: bold; color: #333;">Program / Position:</label>
                        <input type="text" value="${profileData[2]}" readonly style="background-color: #e9ecef; width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;"><br>

                        <label style="font-weight: bold; color: #333;">Year:</label>
                        <input type="text" value="${profileData[3]}" readonly style="background-color: #e9ecef; width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;"><br>
                    </c:if>

                    <hr style="margin: 20px 0; border: 0; border-top: 1px solid #ddd;">
                    <h3 style="color: #0033a0; margin-bottom: 15px;">Security & Contact Updates</h3>

                    <c:if test="${param.error == 'wrongPassword'}">
                        <div style="background-color: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                            <strong>Security Error: Your Current Password was incorrect!</strong>
                        </div>
                    </c:if>

                    <label style="font-weight: bold; color: #333;">Phone Number:</label>
                    <input type="text" name="phoneNo" value="${profileData[1]}" required style="width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #0033a0; border-radius: 4px; box-sizing: border-box;"><br>

                    <label style="font-weight: bold; color: #333;">Current Password (Required to save changes):</label>
                    <input type="password" name="currentPassword" placeholder="Verify your current password" required style="width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 15px; border: 1px solid #dc3545; border-radius: 4px; box-sizing: border-box;"><br>

                    <label style="font-weight: bold; color: #333;">New Password (Leave blank to keep current):</label>
                    <input type="password" name="newPassword" id="newPwdField" placeholder="Enter new password" style="width: 100%; padding: 10px; margin-top: 5px; margin-bottom: 10px; border: 1px solid #0033a0; border-radius: 4px; box-sizing: border-box;">

                    <div style="margin-bottom: 25px; font-size: 14px;">
                        <input type="checkbox" id="showPwdBox" onclick="togglePassword()" style="cursor: pointer;">
                        <label for="showPwdBox" style="cursor: pointer; color: #555;">Show New Password</label>
                    </div>

                    <button type="submit" style="background-color: #0033a0; color: white; width: 100%; padding: 12px; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">Save Changes</button>
                </form>
            </div>
        </div>

        <script>
            function togglePassword() {
                var pwdField = document.getElementById("newPwdField");
                if (pwdField.type === "password") {
                    pwdField.type = "text";
                } else {
                    pwdField.type = "password";
                }
            }
        </script>

        <jsp:include page="footer.jsp" />
    </body>
</html>
