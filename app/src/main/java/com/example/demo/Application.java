package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class Application {

    private static final String APP_VERSION = "1.0.0";

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    /** Root endpoint — basic smoke test */
    @GetMapping("/")
    public String hello() {
        return "Hello from the DevOps pipeline demo app!";
    }

    /** Returns the application version */
    @GetMapping("/version")
    public Map<String, String> version() {
        Map<String, String> info = new LinkedHashMap<>();
        info.put("version", APP_VERSION);
        info.put("artifact", "demo");
        info.put("group", "com.example");
        return info;
    }

    /** Custom health-check endpoint */
    @GetMapping("/health-check")
    public Map<String, String> healthCheck() {
        Map<String, String> status = new LinkedHashMap<>();
        status.put("status", "UP");
        status.put("message", "Application is running fine!");
        return status;
    }

    /** Returns environment / system info — useful for debugging in Kubernetes */
    @GetMapping("/info")
    public Map<String, String> info() {
        Map<String, String> data = new LinkedHashMap<>();
        String hostname = System.getenv("HOSTNAME");
        data.put("hostname", hostname != null ? hostname : "unknown");
        data.put("javaVersion", System.getProperty("java.version"));
        data.put("os", System.getProperty("os.name"));
        data.put("appVersion", APP_VERSION);
        return data;
    }

    /** Returns the current server timestamp */
    @GetMapping("/time")
    public Map<String, String> time() {
        Map<String, String> result = new LinkedHashMap<>();
        result.put("serverTime", LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        return result;
    }

    /** Personalized greeting — demonstrates path variables */
    @GetMapping("/greet/{name}")
    public Map<String, String> greet(@PathVariable String name) {
        Map<String, String> response = new LinkedHashMap<>();
        response.put("message", "Hello, " + name + "! Welcome to the DevOps demo.");
        return response;
    }
}
