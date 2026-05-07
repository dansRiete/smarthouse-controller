FROM eclipse-temurin:21-jdk AS builder
WORKDIR /build
COPY . .
RUN ./mvnw clean package

FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY --from=builder /build/target/SmartHouse-1.0-RELEASE.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
