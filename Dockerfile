# Use an official OpenJDK runtime as a parent image
FROM openjdk:11-jdk

# Set working directory inside the container
WORKDIR /app

# Copy the JAR file or compiled classes from your build output
# Assume your Jenkins build produces a JAR in the 'target' directory
COPY target/*.jar app.jar

# Expose the port your app runs on
EXPOSE 8080

# Run the JAR file
ENTRYPOINT ["java", "-jar", "app.jar"]
