package com.lab.controller;

import com.lab.dao.EventDAO;
import com.lab.model.Event;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "FeedbackServlet", urlPatterns = {"/FeedbackServlet"})
public class FeedbackServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        
        // Get eventID from parameter (from myReservations.jsp)
        String eventID = request.getParameter("eventID");
        String eventName = request.getParameter("eventName");
        
        // If eventID is provided, set it as attribute for the form
        if (eventID != null && !eventID.isEmpty()) {
            request.setAttribute("selectedEventID", eventID);
            request.setAttribute("selectedEventName", eventName);
        }
        
        // Get member's events from database
        String memberID = (String) session.getAttribute("userId");
        EventDAO dao = new EventDAO();
        List<Event> myEvents = dao.getMyReservations(memberID);
        session.setAttribute("myEvents", myEvents);
        
        // Forward to feedback form
        request.getRequestDispatcher("feedbackForm.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("userRole");
        
        // Security: Only MEMBER can submit feedback
        if (!"MEMBER".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        if ("submit".equals(action)) {
            String memberID = (String) session.getAttribute("userId");
            String memberName = (String) session.getAttribute("userName");
            String eventID = request.getParameter("eventID");
            String rating = request.getParameter("rating");
            String comment = request.getParameter("comment");
            String eventName = request.getParameter("eventName");
            
            // Validation
            if (eventID == null || eventID.isEmpty()) {
                response.sendRedirect("feedbackForm.jsp?error=no_event");
                return;
            }
            
            // Get or create feedback list in session
            List<Map<String, String>> feedbackList = (List<Map<String, String>>) session.getAttribute("feedbackList");
            if (feedbackList == null) {
                feedbackList = new ArrayList<>();
                session.setAttribute("feedbackList", feedbackList);
            }
            
            // Check if already submitted feedback for this event
            for (Map<String, String> fb : feedbackList) {
                if (memberID.equals(fb.get("memberID")) && eventID.equals(fb.get("eventID"))) {
                    response.sendRedirect("feedbackForm.jsp?already=true");
                    return;
                }
            }
            
            // Create new feedback entry
            Map<String, String> feedback = new HashMap<>();
            feedback.put("memberID", memberID);
            feedback.put("memberName", memberName);
            feedback.put("eventID", eventID);
            feedback.put("eventName", eventName != null ? eventName : "Unknown Event");
            feedback.put("rating", rating);
            feedback.put("comment", comment);
            feedback.put("date", new SimpleDateFormat("yyyy-MM-dd").format(new Date()));
            feedback.put("replies", "0");
            
            // Save to session
            feedbackList.add(feedback);
            session.setAttribute("feedbackList", feedbackList);
            
            // Redirect with success message
            response.sendRedirect("feedbackForm.jsp?msg=success");
        }
    }
}