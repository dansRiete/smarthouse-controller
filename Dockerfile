# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /build
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
COPY src/ src/
ARG SKIP_TESTS=false
RUN --mount=type=cache,target=/root/.m2 ./mvnw package -B -DskipTests=${SKIP_TESTS}

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=builder /build/target/SmartHouse-1.0-RELEASE.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
