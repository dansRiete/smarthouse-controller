FROM eclipse-temurin:25-jdk AS builder
WORKDIR /build
COPY . .
RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:25-jre
WORKDIR /app
COPY --from=builder /build/target/SmartHouse-1.0-RELEASE.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
