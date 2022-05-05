package com.chher.crm.web.filter;

import javax.servlet.*;
import java.io.IOException;

public class EncodingFilter implements Filter {
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        servletRequest.setCharacterEncoding("UTF-8");
        servletResponse.setContentType("text/html;charset=UTF-8");
        filterChain.doFilter(servletRequest,servletResponse);
    }

    public void init(FilterConfig filterConfig) throws ServletException {

    }

    public void destroy() {

    }
}
