# Use the official Tomcat image with Java
FROM tomcat:9.0-jdk17-openjdk

# Remove the default Tomcat apps to keep it clean
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your generated WAR file into the container
# Replace 'your-project-name.war' with the actual name of your WAR file
COPY dist/COMTECHEventManagement.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]