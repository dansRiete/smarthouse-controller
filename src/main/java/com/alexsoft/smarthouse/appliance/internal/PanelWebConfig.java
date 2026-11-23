package com.alexsoft.smarthouse.appliance.internal;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class PanelWebConfig implements WebMvcConfigurer {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addRedirectViewController("/panel", "/panel/");
        registry.addViewController("/panel/").setViewName("forward:/panel/index.html");
    }
}
