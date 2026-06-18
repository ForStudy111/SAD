package com.lab.controller;

import com.lab.dao.UserDAO;
import com.lab.dao.NotificationDAO;
import com.lab.model.ClubMember;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "SignupServlet", urlPatterns = {"/SignupServlet"})
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("memberID");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phoneNo");
        String program = request.getParameter("program");
        int year = Integer.parseInt(request.getParameter("year"));

        ClubMember newMember = new ClubMember();
        newMember.setMemberID(id);
        newMember.setName(name);
        newMember.setEmail(email);
        newMember.setPassword(password);
        newMember.setPhoneNo(phone);
        newMember.setProgram(program);
        newMember.setYear(year);

        UserDAO dao = new UserDAO();
        boolean isSuccess = dao.registerMember(newMember);

        if (isSuccess) {
            try {
                // NOTIFICATION: Welcome message sent instantly upon successful registration
                new NotificationDAO().addNotification(id, "🎉 Welcome to COMTECH!", "Hello " + name + ", welcome to the official COMTECH Club System! Check out the 'Browse Events' tab to see our upcoming activities.");
            } catch (SQLException ex) {
                Logger.getLogger(SignupServlet.class.getName()).log(Level.SEVERE, null, ex);
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(SignupServlet.class.getName()).log(Level.SEVERE, null, ex);
            }

            response.sendRedirect("login.jsp?msg=registered");
        } else {
            response.sendRedirect("signup.jsp?error=failed");
        }
    }
}
