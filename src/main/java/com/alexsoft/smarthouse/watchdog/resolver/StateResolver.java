package com.alexsoft.smarthouse.watchdog.resolver;

public interface StateResolver {
    boolean supports(String scheme);
    String resolve(String url);
}
