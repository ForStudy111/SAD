/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.lab.controller;

import com.lab.dao.NotificationDAO;
import com.lab.dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author wpy92
 */
@WebServlet("/ManageMembersServlet")
public class ManageMembersServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ManageMembersServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ManageMembersServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        // Security: Ensure ONLY the Committee can access this page
        if (!"COMMITTEE".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp?error=unauthorized");
            return;
        }

        UserDAO dao = new UserDAO();
        String action = request.getParameter("action");

        // Handle the deletion of an inactive member
        if ("delete".equals(action)) {
            String memberIdToDelete = request.getParameter("id");
            dao.deleteMember(memberIdToDelete);

            // Refresh the page with a success message
            response.sendRedirect("ManageMembersServlet?msg=deleted");
            return;
        }

        // Fetch ONLY the standard members (using the existing DAO method)
        request.setAttribute("memberList", dao.getAllStandardMembers());

        // Send to your specific Committee JSP view
        request.getRequestDispatcher("committeeManageMembers.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!"COMMITTEE".equals(session.getAttribute("userRole"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String[] selectedMembers = request.getParameterValues("selectedMembers"); // Gets all checked boxes

        if (selectedMembers != null && selectedMembers.length > 0) {
            UserDAO userDAO = new UserDAO();
            NotificationDAO notifDAO = new NotificationDAO();

            if ("bulkDelete".equals(action)) {
                for (String memberId : selectedMembers) {
                    userDAO.deleteMember(memberId);
                }
                response.sendRedirect("ManageMembersServlet?msg=bulkDeleted");

            } else if ("sendWarning".equals(action)) {
                for (String memberId : selectedMembers) {
                    try {
                        notifDAO.addNotification(memberId, "COMTECH Inactivity Warning",
                                "Dear member, we have noticed a lack of participation in recent club activities. "
                                        + "Please stay focused and engage in upcoming events to maintain your active status in the club.");
                    } catch (SQLException ex) {
                        Logger.getLogger(ManageMembersServlet.class.getName()).log(Level.SEVERE, null, ex);
                    } catch (ClassNotFoundException ex) {
                        Logger.getLogger(ManageMembersServlet.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
                response.sendRedirect("ManageMembersServlet?msg=warningSent");
            }
        } else {
            // If they clicked a button without checking any boxes
            response.sendRedirect("ManageMembersServlet?error=noneSelected");
        }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
