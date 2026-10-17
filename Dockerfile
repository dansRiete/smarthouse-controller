FROM eclipse-temurin:21-jdk AS builder
WORKDIR /build
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline -B
COPY src/ src/
RUN ./mvnw package -B

FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY --from=builder /build/target/SmartHouse-1.0-RELEASE.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
