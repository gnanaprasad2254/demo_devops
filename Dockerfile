# STEP 4b: Multi-stage build - compiles with Maven, then ships a slim runtime image.
# Build:  docker build -t <nexus-host>:8082/demo-app:latest .
# Push:   docker push <nexus-host>:8082/demo-app:latest   (Nexus acting as Docker registry)

FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY app/pom.xml .
RUN mvn dependency:go-offline
COPY app/src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
